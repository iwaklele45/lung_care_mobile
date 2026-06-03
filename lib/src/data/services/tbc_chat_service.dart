import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Gemini-backed chat service focused on TBC education, via Firebase AI Logic.
class TbcChatService {
  TbcChatService() {
    final model = FirebaseAI.googleAI(
      auth: FirebaseAuth.instance,
    ).generativeModel(
      // gemini-2.0-flash sudah shutdown per 1 Juni 2026.
      // Free tier gemini-2.5-flash: 5 RPM — retry logic menangani rate limit.
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
        'Kamu adalah "Asisten TBC" dari aplikasi LungCare+. Jawab dalam Bahasa '
        'Indonesia yang ramah, singkat, dan mudah dipahami pasien. Fokus hanya '
        'pada edukasi dan pengobatan Tuberkulosis (TBC): gejala, pengobatan '
        'OAT, efek samping, kepatuhan minum obat, pencegahan, dan kontrol '
        'rutin. Jika pertanyaan di luar topik TBC/kesehatan, arahkan kembali '
        'dengan sopan. Selalu ingatkan untuk berkonsultasi dengan petugas '
        'kesehatan atau Puskesmas untuk diagnosis dan keputusan medis. '
        'Jangan memberikan diagnosis pasti.',
      ),
    );
    _chat = model.startChat();
  }

  late final ChatSession _chat;

  static const _maxRetries = 2;

  /// Sends [message] to Gemini and returns the assistant reply text.
  /// Retries up to [_maxRetries] times on server/rate-limit errors.
  Future<String> send(String message) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _chat.sendMessage(Content.text(message));
        return response.text?.trim().isNotEmpty == true
            ? response.text!.trim()
            : 'Maaf, saya belum bisa menjawab itu. Coba tanyakan hal lain seputar TBC.';
      } catch (e) {
        final isRetryable = e.toString().contains('500') ||
            e.toString().contains('503') ||
            e.toString().contains('429') ||
            e.toString().contains('Quota exceeded') ||
            e.toString().contains('high demand');

        if (isRetryable && attempt < _maxRetries) {
          // Tunggu sebelum retry (2s, 4s)
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        rethrow;
      }
    }
    // Tidak akan tercapai, tapi diperlukan compiler
    throw Exception('Gagal menghubungi server setelah $_maxRetries percobaan.');
  }
}
