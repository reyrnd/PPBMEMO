import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Status sakelar berdasarkan opsi di berkas TSX
  bool _mentionsAndReplies = true;
  bool _workspaceInvitations = true;
  bool _taskUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Judul Section Preferensi
              const Text(
                'Preferensi notifikasi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Kontainer Putih Daftar Pengaturan (White Box Style)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.whiteBackgroundField,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: [
                    _buildSettingSwitchRow(
                      title: 'Sebutan dan balasan',
                      value: _mentionsAndReplies,
                      onChanged: (val) =>
                          setState(() => _mentionsAndReplies = val),
                    ),
                    _buildSettingSwitchRow(
                      title: 'Undangan ruang kerja',
                      value: _workspaceInvitations,
                      onChanged: (val) =>
                          setState(() => _workspaceInvitations = val),
                    ),
                    _buildSettingSwitchRow(
                      title: 'Pembaruan tugas',
                      value: _taskUpdates,
                      onChanged: (val) => setState(() => _taskUpdates = val),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Tombol Simpan di Bagian Bawah
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Simpan preferensi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Widgets / Component Slicing
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.canvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Notifikasi',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
      ),
    );
  }

  Widget _buildSettingSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.line, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            // Mengatur warna track saat aktif dan tidak aktif secara aman
            activeTrackColor: AppTheme.ink,
            inactiveThumbColor: AppTheme.faint,
            inactiveTrackColor: AppTheme.surface,
          ),
        ],
      ),
    );
  }
}
