import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  var _newComments = true;
  var _workspaceInvitations = true;
  var _memberMemoUpdates = true;
  var _dailySummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. APP BAR CLEAN SETUP ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Ikon avatar kanan atas dihapus demi konsistensi fungsional halaman pengaturan
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // --- 2. TEKS PETUNJUK HEADER ---
            const Text(
              'Atur preferensi pembaruan otomatis untuk aktivitas catatan tim dan kolaborasi tugas Anda.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. KONTEN UTAMA: BOKS DAFTAR SAKELAR ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Komentar baru',
                    subtitle:
                        'Dapatkan pemberitahuan saat anggota tim menanggapi memo Anda',
                    value: _newComments,
                    onChanged: (value) => setState(() => _newComments = value),
                  ),
                  const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16),
                  _buildSwitchRow(
                    title: 'Undangan workspace',
                    subtitle:
                        'Pemberitahuan ketika Anda ditambahkan ke tim atau workspace baru',
                    value: _workspaceInvitations,
                    onChanged: (value) =>
                        setState(() => _workspaceInvitations = value),
                  ),
                  const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16),
                  _buildSwitchRow(
                    title: 'Memo diubah anggota',
                    subtitle:
                        'Pemberitahuan saat catatan bersama diedit oleh rekan kolaborator',
                    value: _memberMemoUpdates,
                    onChanged: (value) =>
                        setState(() => _memberMemoUpdates = value),
                  ),
                  const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16),
                  _buildSwitchRow(
                    title: 'Ringkasan harian',
                    subtitle:
                        'Rangkuman aktivitas proyek dan tugas setiap pukul 08.00 pagi',
                    value: _dailySummary,
                    onChanged: (value) => setState(() => _dailySummary = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. CATATAN KAKI: INFORMASI DARURAT ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline,
                    size: 18, color: AppTheme.textSecondary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pemberitahuan darurat atau tenggat waktu tugas mendesak tetap akan dikirimkan.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk merender baris Switch modern sesuai contoh gambar
  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Menggunakan Switch.adaptive dengan pewarnaan custom hitam minimalis
          Switch.adaptive(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.textPrimary,
            inactiveTrackColor: Colors.black12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
