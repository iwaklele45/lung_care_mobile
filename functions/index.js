"use strict";

const crypto = require("crypto");
const admin = require("firebase-admin");
const functions = require("firebase-functions/v1");
const nodemailer = require("nodemailer");
const {HttpsError} = functions.https;
const logger = functions.logger;

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

const collection = db.collection("password_reset_otps");
const otpTtlMs = 10 * 60 * 1000;
const resetTokenTtlMs = 10 * 60 * 1000;
const resendCooldownMs = 60 * 1000;
const maxAttempts = 5;
const otpPepper =
  process.env.OTP_PEPPER ||
  process.env.GCLOUD_PROJECT ||
  process.env.FIREBASE_CONFIG ||
  "lung-care-local-dev";

function requireString(value, field) {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} wajib diisi.`);
  }
  return value.trim();
}

function normalizeIdentifier(rawIdentifier) {
  const identifier = rawIdentifier.trim();
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (emailPattern.test(identifier)) {
    return {
      type: "email",
      normalized: identifier.toLowerCase(),
      lookupValues: [identifier.toLowerCase()],
    };
  }

  const digits = identifier.replace(/[^\d+]/g, "");
  const numberOnly = digits.replace(/\D/g, "");
  let e164 = null;
  if (digits.startsWith("+")) {
    e164 = `+${numberOnly}`;
  } else if (numberOnly.startsWith("62")) {
    e164 = `+${numberOnly}`;
  } else if (numberOnly.startsWith("0")) {
    e164 = `+62${numberOnly.substring(1)}`;
  }

  if (!e164 || !/^\+62\d{8,13}$/.test(e164)) {
    throw new HttpsError(
      "invalid-argument",
      "Masukkan email atau nomor HP Indonesia yang valid.",
    );
  }

  const local = `0${e164.substring(3)}`;
  const withoutPlus = e164.substring(1);
  return {
    type: "phone",
    normalized: e164,
    lookupValues: Array.from(new Set([e164, local, withoutPlus, identifier])),
  };
}

function hashValue(value) {
  return crypto.createHmac("sha256", otpPepper).update(value).digest("hex");
}

function createOtp() {
  return crypto.randomInt(0, 1000000).toString().padStart(6, "0");
}

function createToken() {
  return crypto.randomBytes(32).toString("base64url");
}

function toTimestamp(ms) {
  return admin.firestore.Timestamp.fromMillis(ms);
}

function millis(timestamp) {
  return timestamp.toMillis();
}

function maskEmail(email) {
  const [name, domain] = email.split("@");
  const visible = name.length <= 2 ? name[0] : `${name[0]}${name[name.length - 1]}`;
  return `${visible}${"*".repeat(Math.max(name.length - visible.length, 3))}@${domain}`;
}

function maskPhone(phone) {
  return `${phone.substring(0, 5)}****${phone.substring(phone.length - 3)}`;
}

function getMailTransport() {
  const email = process.env.GMAIL_EMAIL;
  const password = process.env.GMAIL_PASSWORD;
  if (!email || !password) return null;
  return nodemailer.createTransport({
    service: "gmail",
    auth: {user: email, pass: password},
  });
}

async function sendOtpEmail({destination, otp, channel}) {
  if (channel !== "email") return;
  const transport = getMailTransport();
  if (!transport) {
    logger.warn("Gmail SMTP not configured. OTP not sent via email.");
    return;
  }
  const gmailEmail = process.env.GMAIL_EMAIL;
  try {
    await transport.sendMail({
      from: `"LungCare+" <${gmailEmail}>`,
      to: destination,
      subject: "Kode Reset Password LungCare+",
      html: [
        "<div style='font-family:sans-serif;max-width:480px;margin:0 auto;padding:24px'>",
        "<h2 style='color:#1565C0'>LungCare+</h2>",
        "<p>Halo,</p>",
        "<p>Berikut kode OTP untuk mereset password Anda:</p>",
        `<div style='background:#f5f5f5;padding:16px;text-align:center;border-radius:8px;margin:16px 0'>`,
        `<span style='font-size:32px;font-weight:bold;letter-spacing:8px;color:#1565C0'>${otp}</span>`,
        "</div>",
        "<p>Kode ini berlaku selama <strong>10 menit</strong>.</p>",
        "<p>Jika Anda tidak meminta reset password, abaikan email ini.</p>",
        "<hr style='border:none;border-top:1px solid #eee;margin:24px 0'>",
        "<p style='color:#999;font-size:12px'>Email ini dikirim otomatis oleh LungCare+.</p>",
        "</div>",
      ].join(""),
    });
    logger.info("OTP email sent", {to: destination});
  } catch (error) {
    logger.error("Failed to send OTP email", error);
  }
}

async function findAccount(identifier) {
  if (identifier.type === "email") {
    try {
      const user = await auth.getUserByEmail(identifier.normalized);
      return {
        uid: user.uid,
        destination: user.email || identifier.normalized,
        channel: "email",
      };
    } catch (error) {
      if (error.code !== "auth/user-not-found") {
        logger.warn("Email lookup failed", error);
      }
      return null;
    }
  }

  const snapshot = await db
    .collection("users")
    .where("phoneNumber", "in", identifier.lookupValues.slice(0, 10))
    .limit(1)
    .get();

  if (snapshot.empty) return null;
  const userDoc = snapshot.docs[0];
  return {
    uid: userDoc.id,
    destination: identifier.normalized,
    channel: "sms",
  };
}

function responseFromDoc(doc, data, demoCode) {
  return {
    requestId: doc.id,
    maskedDestination: data.maskedDestination,
    channel: data.channel,
    resendAvailableAt: millis(data.resendAvailableAt),
    demoCode,
  };
}

exports.requestPasswordReset = functions.https.onCall(async (payload) => {
  const rawIdentifier = requireString(payload && payload.identifier, "Identifier");
  const identifier = normalizeIdentifier(rawIdentifier);
  const account = await findAccount(identifier);
  if (!account) {
    throw new HttpsError(
      "not-found",
      "Akun dengan email atau nomor HP tersebut tidak ditemukan.",
    );
  }

  const otp = createOtp();
  const now = Date.now();
  const doc = collection.doc();

  const channel = account.channel;
  const destination = account.destination;
  const maskedDestination = channel === "email" ? maskEmail(destination) : maskPhone(destination);

  await doc.set({
    uid: account.uid,
    identifierHash: hashValue(identifier.normalized),
    channel,
    destination,
    maskedDestination,
    otpHash: hashValue(otp),
    attemptCount: 0,
    expiresAt: toTimestamp(now + otpTtlMs),
    resendAvailableAt: toTimestamp(now + resendCooldownMs),
    resetTokenHash: null,
    resetTokenExpiresAt: null,
    consumedAt: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info("Password reset OTP created", {
    requestId: doc.id,
    channel,
    accountFound: Boolean(account),
  });

  await sendOtpEmail({destination, otp, channel});

  return responseFromDoc(doc, (await doc.get()).data(), otp);
});

exports.resendPasswordResetCode = functions.https.onCall(async (payload) => {
  const requestId = requireString(payload && payload.requestId, "Request ID");
  const doc = collection.doc(requestId);
  const snapshot = await doc.get();
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Permintaan reset tidak ditemukan.");
  }

  const data = snapshot.data();
  const now = Date.now();
  if (data.consumedAt) {
    throw new HttpsError("failed-precondition", "Kode reset sudah digunakan.");
  }
  if (data.resendAvailableAt.toMillis() > now) {
    throw new HttpsError("resource-exhausted", "Tunggu sebelum mengirim ulang kode.");
  }

  const otp = createOtp();
  await doc.update({
    otpHash: hashValue(otp),
    attemptCount: 0,
    expiresAt: toTimestamp(now + otpTtlMs),
    resendAvailableAt: toTimestamp(now + resendCooldownMs),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const updated = (await doc.get()).data();

  await sendOtpEmail({
    destination: updated.destination || updated.maskedDestination,
    otp,
    channel: updated.channel,
  });

  return responseFromDoc(doc, updated, otp);
});

exports.verifyPasswordResetCode = functions.https.onCall(async (payload) => {
  const requestId = requireString(payload && payload.requestId, "Request ID");
  const code = requireString(payload && payload.code, "Kode");
  if (!/^\d{6}$/.test(code)) {
    throw new HttpsError("invalid-argument", "Kode harus 6 digit.");
  }

  const doc = collection.doc(requestId);
  const resetToken = createToken();
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(doc);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Permintaan reset tidak ditemukan.");
    }
    const data = snapshot.data();
    const now = Date.now();
    if (!data.uid) {
      throw new HttpsError(
        "failed-precondition",
        "Permintaan reset lama tidak valid. Silakan minta kode baru.",
      );
    }
    if (data.consumedAt) {
      throw new HttpsError("failed-precondition", "Kode reset sudah digunakan.");
    }
    if (data.expiresAt.toMillis() < now) {
      throw new HttpsError("deadline-exceeded", "Kode sudah kedaluwarsa.");
    }
    if ((data.attemptCount || 0) >= maxAttempts) {
      throw new HttpsError("resource-exhausted", "Terlalu banyak percobaan kode.");
    }
    if (data.otpHash !== hashValue(code)) {
      transaction.update(doc, {
        attemptCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw new HttpsError("invalid-argument", "Kode verifikasi tidak valid.");
    }

    transaction.update(doc, {
      resetTokenHash: hashValue(resetToken),
      resetTokenExpiresAt: toTimestamp(now + resetTokenTtlMs),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {resetToken};
});

exports.confirmPasswordReset = functions.https.onCall(async (payload) => {
  const resetToken = requireString(payload && payload.resetToken, "Reset token");
  const newPassword = requireString(payload && payload.newPassword, "Password baru");
  if (newPassword.length < 6) {
    throw new HttpsError("invalid-argument", "Password minimal 6 karakter.");
  }

  const tokenHash = hashValue(resetToken);
  const snapshot = await collection
    .where("resetTokenHash", "==", tokenHash)
    .limit(1)
    .get();

  if (snapshot.empty) {
    throw new HttpsError("invalid-argument", "Token reset tidak valid.");
  }

  const doc = snapshot.docs[0].ref;
  let uid = null;
  await db.runTransaction(async (transaction) => {
    const latest = await transaction.get(doc);
    const data = latest.data();
    const now = Date.now();
    if (!data.uid || data.consumedAt) {
      throw new HttpsError("failed-precondition", "Token reset sudah digunakan.");
    }
    if (!data.resetTokenExpiresAt || data.resetTokenExpiresAt.toMillis() < now) {
      throw new HttpsError("deadline-exceeded", "Token reset sudah kedaluwarsa.");
    }
    uid = data.uid;
    transaction.update(doc, {
      consumedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await auth.updateUser(uid, {password: newPassword});
  return {success: true};
});
