import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MemoEditorScreen extends StatelessWidget {
  const MemoEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. APP BAR UTAMA ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'Editor Catatan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.textPrimary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- AREA SCROLLABLE KONTEN ---
            Expanded(
              child: SingleChildScrollView(
                // Menggunakan padding standar projek Anda
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 2. SUB-BAR (STATUS SIMPAN & AVATAR EDITORS) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  size: 20, color: AppTheme.textPrimary),
                              onPressed: () {},
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 6, color: Color(0xFF22C55E)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tersimpan otomatis',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildEditorAvatars(),
                            const SizedBox(width: 8),
                            Stack(
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    color: AppTheme.textPrimary, size: 22),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                    constraints: const BoxConstraints(
                                        minWidth: 12, minHeight: 12),
                                    child: const Text('4',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.more_vert,
                                color: AppTheme.textPrimary, size: 22),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 3. BADGE WORKSPACE SELECTOR ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open,
                              size: 14, color: AppTheme.textSecondary),
                          SizedBox(width: 6),
                          Text('Proyek Robot AUV',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              size: 14, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 4. JUDUL & SUBTITLE EDITOR ---
                    const Text(
                      'Pengujian Lapangan Modul Son',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Terakhir diedit Farhan K. • 5 mnt lalu',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // --- 5. ISI CATATAN TEKS ---
                    const Text(
                      'Hasil kalibrasi frekuensi modul sonar menunjukkan deviasi sinyal pantul sebesar ±1.8% pada kedalaman 3 meter di kolam pengujian. Respon akustik transduser masih stabil pada tegangan operasional 12V DC.\n\nCatatan penting untuk tim hardware:',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // --- 6. SECTION LAMPIRAN ---
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lampiran (3)',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary)),
                        Text('Geser untuk melihat semua',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // LIST HORIZONTAL LAMPIRAN MEDIA
                    SizedBox(
                      height: 165,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        children: [
                          _buildImageAttachment(
                              'uji_sonar_kolam.jpg', '2.1 MB'),
                          const SizedBox(width: 12),
                          _buildVideoAttachment(
                              'rekaman_akustik.mp4', '14.6 MB'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 7. COLLABORATOR LIVE FOOTER ---
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: Color(0xFF22C55E)),
                        const SizedBox(width: 8),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary),
                            children: [
                              TextSpan(
                                  text: 'Sari ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary)),
                              TextSpan(text: 'sedang mengedit... •••'),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // --- 8. BOTTOM TOOLBAR (DOCK BOTTOM STICKY) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.image_outlined,
                              color: AppTheme.textPrimary, size: 22),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.videocam_outlined,
                              color: AppTheme.textPrimary, size: 22),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.attach_file,
                              color: AppTheme.textPrimary, size: 22),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.check_box_outlined,
                              color: AppTheme.textPrimary, size: 22),
                          onPressed: () {}),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Simpan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- WIDGET HELPERS ---
  Widget _buildEditorAvatars() {
    return SizedBox(
      width: 42,
      height: 24,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(0xFF111827),
                  child: Text('DN',
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))),
            ),
          ),
          Positioned(
            left: 14,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey[400],
                  child: const Text('BS',
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAttachment(String name, String size) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 105,
                  width: double.infinity,
                  color: Colors.blueGrey[100],
                  child: const Center(
                      child: Icon(Icons.image,
                          color: Colors.blueGrey,
                          size: 30)), // Simulasi foto kolam teknik
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(size,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoAttachment(String name, String size) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 105,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.white30, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('0:42',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(size,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
