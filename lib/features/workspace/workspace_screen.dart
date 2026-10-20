import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class WorkspaceDetailScreen extends StatelessWidget {
  const WorkspaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // --- 1. APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'Workspace',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.textPrimary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. HEADER INFO & TITLE ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Kategori & Status Sinkronisasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.precision_manufacturing_outlined,
                                  size: 12, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text('Robotika & Elektro',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.sync,
                                size: 12, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Text('Sinkron otomatis',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Judul Workspace
                    const Text(
                      'Proyek Robot AUV',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tempat kolaborasi dan dokumentasi teknis tim robot bawah air mandiri.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.3),
                    ),
                    const SizedBox(height: 16),
                    // Anggota Tim & Tombol Undang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAvatarGroup(),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt_1,
                              size: 14, color: AppTheme.textPrimary),
                          label: const Text('+ Undang',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // --- 3. METRICS GRID ROW ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildMetricCard('18', 'Memo Aktif')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricCard('6', 'Berkas\nCAD/PDF')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetricCard('6', 'Anggota Tim')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. ACTION BUTTONS ROW ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle_outline,
                            size: 16, color: Colors.white),
                        label: const Text('Buat Memo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.hub_outlined,
                            size: 16, color: AppTheme.textPrimary),
                        label: const Text('Kanvas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search,
                            size: 18, color: AppTheme.textPrimary),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 5. SUB-TAB SEGMENT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      Expanded(child: _buildSubTab('Kanvas', false)),
                      Expanded(child: _buildSubTab('Library', true)),
                      Expanded(child: _buildSubTab('Aktivitas', false)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- 6. VISUAL CANVAS CARD PREVIEW ---
              _buildCanvasPreviewCard(),
              const SizedBox(height: 24),

              // --- 7. MEMO TERBARU SECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('Memo Terbaru',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary)),
                        SizedBox(width: 6),
                        CircleAvatar(
                            radius: 9,
                            backgroundColor: Color(0xFFE2E8F0),
                            child: Text('3',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary))),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      label: const Text('Urutkan',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: AppTheme.textSecondary),
                    )
                  ],
                ),
              ),
// KARTU MEMO 1 (Pinned)
              _buildMemoItem(
                isPinned: true,
                timeAgo: '25 mnt lalu',
                title: 'Catatan Rapat Tim: Pembagian Modul...',
                description:
                    'Pengujian sensor sonar bawah air dijadwalkan hari Jumat di kolam rekayasa. Pastikan modul ESP32 dan...',
                hasAttachment: true,
                attachmentName: 'spek_sonar_v2.pdf',
                attachmentSize: '1.8 MB',
                userInitials: 'FK',
                userName: 'Farhan K.',
                commentsCount: 4,
              ),
// KARTU MEMO 2 (With Tags)
              _buildMemoItem(
                isPinned: false,
                timeAgo: '3 jam lalu',
                title: 'Hasil Uji Baterai LiPo & Konsumsi Daya...',
                description:
                    'Konsumsi arus rata-rata mencapai 14.2A pada beban penuh. Diperlukan penambahan heatsink pada driver...',
                tags: ['#Hardware', '#UjiCoba', '#PowerSupply'],
                userInitials: 'NP',
                userName: 'Nabila P.',
                viewsCount: 2,
              ),
// KARTU MEMO 3 (Progress Bar / Checklist)
              _buildMemoItem(
                isPinned: false,
                timeAgo: 'Kemarin',
                title: 'Daftar Komponen Cadangan Kontes AUV...',
                description:
                    'Checklist 8/10 barang terverifikasi. Sensor tekanan Bar30 dan modul kompas kompensasi kemiringan...',
                progressText: '8/10 Selesai',
                progressValue: 0.8,
                progressFooter: 'Tersisa: O-ring cadangan & baterai 4S',
                userInitials: 'DA',
                userName: 'Dimas A.',
                actionText: 'Buka Checklist >',
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPERS ---
  Widget _buildAvatarGroup() {
    final list = [
      {'text': 'FK', 'color': const Color(0xFFE2E8F0)},
      {'text': 'SR', 'color': const Color(0xFFDCEFFE)},
      {'text': 'NP', 'color': const Color(0xFFE0E7FF)},
      {'text': 'DA', 'color': const Color(0xFFFEE2E2)},
    ];
    return Row(
      children: [
        SizedBox(
          width: 90,
          height: 28,
          child: Stack(
            children: List.generate(list.length, (index) {
              return Positioned(
                left: index * 18,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: list[index]['color'] as Color,
                    child: Text(list[index]['text'] as String,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary)),
                  ),
                ),
              );
            }),
          ),
        ),
        const Text('+2  6 aktif',
            style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildSubTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildCanvasPreviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                    child: const Icon(Icons.hub_outlined,
                        size: 14, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kanvas Visual Proyek',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Update 12 mnt lalu oleh Farhan',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4)),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    SizedBox(width: 4),
                    Text('3 online',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
// AREA KANVAS STATIS (Simulasi Hybrid Board Terbatas)
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Stack(
              children: [
// Titik Pusat Grid atau Node Tengah Palsu
                Center(
                    child: Container(
                        width: 40,
                        height: 24,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0), shape: BoxShape.circle))),
// Item Node 1: Uji Thruster
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Uji Thruster',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Kolam teknik pkl 14:00',
                            style: TextStyle(
                                fontSize: 8, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
// Item Node 2: Skema ESP32
                Positioned(
                  top: 16,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Text('Skema ESP32 ',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D))),
                        Text('Pin RX/TX diverifikasi',
                            style: TextStyle(
                                fontSize: 8, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ),
// Item Node 3: Bab 3: Jumat!
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Bab 3: Jumat!',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
// Tombol Komponen Tambahan kanan bawah
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12)),
                    child: const Icon(Icons.unfold_more_outlined,
                        size: 14, color: AppTheme.textSecondary),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
// Tombol Masuk ke Kanvas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Masuk ke Kanvas Visual',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                Icon(Icons.arrow_forward,
                    size: 14, color: AppTheme.textPrimary),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemoItem({
    required bool isPinned,
    required String timeAgo,
    required String title,
    required String description,
    bool hasAttachment = false,
    String? attachmentName,
    String? attachmentSize,
    List? tags,
    String? progressText,
    double? progressValue,
    String? progressFooter,
    required String userInitials,
    required String userName,
    int? commentsCount,
    int? viewsCount,
    String? actionText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Header Item (Pin/Progress status & Waktu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPinned)
                const Row(
                  children: [
                    Icon(Icons.push_pin,
                        size: 12, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text('Disematkan',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              else if (progressText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 11, color: Color(0xFF15803D)),
                      const SizedBox(width: 4),
                      Text(progressText,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                const SizedBox(),
              Text(timeAgo,
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 8),
// Judul & Detail Deskripsi
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.3)),
          // KONDISIONAL KONTEN: 1. Jika ada berkas PDF attachment
          if (hasAttachment && attachmentName != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEDF2F7))),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(attachmentName,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500))),
                  Text(attachmentSize ?? '',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary)),
                ],
              ),
            )
          ],
          // KONDISIONAL KONTEN: 2. Jika ada Hashtags tag
          if (tags != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: tags
                  .map((tag) => Text(tag,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500)))
                  .toList(),
            )
          ],
          // KONDISIONAL KONTEN: 3. Jika berupa checklist dengan Progress Bar
          if (progressValue != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF16A34A),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            if (progressFooter != null) ...[
              const SizedBox(height: 6),
              Text(progressFooter,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ]
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          // Footer Card (Profil Kreator & Metrik Interaksi)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(userInitials,
                          style: const TextStyle(
                              fontSize: 9, color: AppTheme.textSecondary))),
                  const SizedBox(width: 6),
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                children: [
                  if (commentsCount != null) ...[
                    const Icon(Icons.chat_bubble_outline,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('$commentsCount',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.bookmark_border,
                        size: 14, color: AppTheme.textSecondary),
                  ],
                  if (viewsCount != null) ...[
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('$viewsCount',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                  if (actionText != null)
                    Text(actionText,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
