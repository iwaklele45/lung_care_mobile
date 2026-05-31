import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/services/tbc_chat_service.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';

class _Message {
  const _Message(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

/// "Asisten TBC" chatbot page backed by Gemini via Firebase AI.
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = TbcChatService();
  bool _sending = false;

  final List<_Message> _messages = [
    const _Message(
      'Halo! Saya Asisten TBC dari Serene Care. Ada yang bisa saya bantu hari '
      'ini mengenai edukasi atau pengobatan TBC?',
      fromUser: false,
    ),
  ];

  static const _quickReplies = [
    'Apa itu TBC?',
    'Efek samping obat',
    'Jadwal kontrol',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Message(trimmed, fromUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();
    try {
      final reply = await _chatService.send(trimmed);
      if (!mounted) return;
      setState(() => _messages.add(_Message(reply, fromUser: false)));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          const _Message(
            'Maaf, terjadi gangguan koneksi. Coba lagi sebentar ya.',
            fromUser: false,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      drawer: const HamburgerMenu(selectedIndex: 2),
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.ternary,
              child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Asisten TBC',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Serene Care • Online',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _TypingBubble();
                return _Bubble(message: _messages[i]);
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quickReplies
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(q),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: Color(0xFFCCE0F5)),
                        onPressed: _sending ? null : () => _send(q),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _Composer(
            controller: _controller,
            enabled: !_sending,
            onSend: () => _send(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFE8EEF6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isUser ? Colors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: AppColors.white,
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: AppColors.nautral),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.bodyColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: enabled ? onSend : null,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: enabled ? AppColors.primary : AppColors.nautral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFE8EEF6)),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
