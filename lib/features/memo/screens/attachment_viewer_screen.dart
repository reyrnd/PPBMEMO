import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class AttachmentViewerScreen extends StatelessWidget {
  const AttachmentViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data meta file dari berkas TSX (Contoh kasus pratinjau Video/Photo)
    const String fileName = 'Workshop whiteboard.jpg';
    const String fileTypeInfo = 'Photo · 2.4 MB';
    const bool isVideo = false;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: _buildAppBar(context, fileName, fileTypeInfo),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Dark Asset Media Viewer Container (bg-ink)
              Container(
                width: double.infinity,
                height: 288, // Setara h-72 di Tailwind
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [AppTheme.shadowCard],
                ),
                alignment: Alignment.center,
                child: Icon(
                  // Hapus modifier const di atas, pindahkan ke widget Icon jika diperlukan
                  isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                  size: 48,
                  color: Colors.white,
                  // Baris strokeWidth: 1.4, SUDAH DIHAPUS agar tidak error lagi
                ),
              ),
              const SizedBox(height: 16),

              // 2. File Details Card Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.whiteBackgroundField,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grid Info 2 baris (Sesuai struktur TSX)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Added',
                                  style: TextStyle(
                                      fontSize: 10, color: AppTheme.faint)),
                              SizedBox(height: 4),
                              Text('May 24, 2025',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Workspace',
                                  style: TextStyle(
                                      fontSize: 10, color: AppTheme.faint)),
                              SizedBox(height: 4),
                              Text('Northstar Studio',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Widgets / Component Slicing
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String title, String subtitle) {
    return AppBar(
      backgroundColor: AppTheme.canvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.muted,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.ink),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
