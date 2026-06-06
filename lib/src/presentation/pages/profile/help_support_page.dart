import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // ── FAQ data ──────────────────────────────────────────────────────────────
  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'Bagaimana cara menambahkan jadwal obat?',
      answer:
          'Buka halaman "Jadwal Obat" melalui menu utama, lalu tekan tombol + '
          'di pojok kanan bawah. Isi nama obat, dosis, dan waktu minum, '
          'kemudian tekan "Simpan".',
    ),
    _FaqItem(
      question: 'Apakah data saya aman?',
      answer:
          'Ya. Data Anda disimpan secara terenkripsi di server Firebase dan '
          'hanya dapat diakses oleh akun Anda sendiri. Kami tidak membagikan '
          'data pribadi kepada pihak ketiga.',
    ),
    _FaqItem(
      question: 'Bagaimana cara mengubah profil saya?',
      answer:
          'Buka tab "Profil" lalu tekan "Edit Profil". Anda dapat mengubah '
          'nama, nomor WhatsApp, dan alamat.',
    ),
    _FaqItem(
      question: 'Notifikasi tidak muncul, apa yang harus dilakukan?',
      answer:
          'Pastikan izin notifikasi untuk LungCare+ sudah diaktifkan di '
          'pengaturan HP Anda. Jika masih bermasalah, coba logout lalu '
          'login kembali.',
    ),
    _FaqItem(
      question: 'Apakah layanan ini tersedia di luar Surabaya?',
      answer:
          'Saat ini LungCare+ hanya tersedia untuk wilayah Kota Surabaya. '
          'Kami berencana memperluas cakupan di masa mendatang.',
    ),
  ];

  // ── Contact actions ───────────────────────────────────────────────────────
  Future<void> _openWhatsApp(BuildContext context) async {
    // Replace with real support number
    final uri = Uri.parse('https://wa.me/6281234567890?text=Halo%20LungCare%2B%2C%20saya%20butuh%20bantuan.');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@lungcareplus.id',
      queryParameters: {'subject': 'Bantuan LungCare+'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6AB0F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent_rounded, size: 36, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Ada yang bisa kami bantu?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hubungi tim kami atau temukan jawaban\ndi pertanyaan yang sering ditanyakan.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Contact options ───────────────────────────────────────────
            const _SectionTitle(text: 'HUBUNGI KAMI'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp',
                    subtitle: 'Chat langsung',
                    color: const Color(0xFF25D366),
                    onTap: () => _openWhatsApp(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    subtitle: 'Kirim pesan',
                    color: AppColors.primary,
                    onTap: () => _openEmail(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── FAQ section ──────────────────────────────────────────────
            const _SectionTitle(text: 'PERTANYAAN UMUM (FAQ)'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE6F4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExpansionPanelList.radio(
                  elevation: 0,
                  expandedHeaderPadding: EdgeInsets.zero,
                  dividerColor: const Color(0xFFEDF2F7),
                  children: _faqs
                      .asMap()
                      .entries
                      .map(
                        (entry) => ExpansionPanelRadio(
                          value: entry.key,
                          canTapOnHeader: true,
                          headerBuilder: (_, isExpanded) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? AppColors.primary
                                        : AppColors.ternary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.question_mark_rounded,
                                      size: 14,
                                      color: isExpanded
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value.question,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isExpanded
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                            child: Text(
                              entry.value.answer,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.nautral,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── App info ─────────────────────────────────────────────────
            const _SectionTitle(text: 'TENTANG APLIKASI'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE6F4)),
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'Versi Aplikasi', value: '1.0.0'),
                  Divider(color: Color(0xFFEDF2F7), height: 20),
                  _InfoRow(label: 'Pengembang', value: 'Tim LungCare+'),
                  Divider(color: Color(0xFFEDF2F7), height: 20),
                  _InfoRow(label: 'Wilayah Layanan', value: 'Surabaya'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper models & widgets ─────────────────────────────────────────────────

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        letterSpacing: 0.6,
        fontSize: 13,
        color: AppColors.nautral,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE6F4)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.nautral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.nautral,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
