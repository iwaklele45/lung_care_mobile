import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Gemini-backed chat service focused on TBC education, via Firebase AI Logic.
class TbcChatService {
  TbcChatService() {
    final model = FirebaseAI.googleAI(
      auth: FirebaseAuth.instance,
    ).generativeModel(
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

  /// Sends [message] to Gemini and returns the assistant reply text.
  Future<String> send(String message) async {
    final response = await _chat.sendMessage(Content.text(message));
    return response.text?.trim().isNotEmpty == true
        ? response.text!.trim()
        : 'Maaf, saya belum bisa menjawab itu. Coba tanyakan hal lain seputar TBC.';
  }
}

