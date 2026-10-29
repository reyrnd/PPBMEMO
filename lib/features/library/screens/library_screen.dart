import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/library/widgets/create_sheet.dart';
import 'package:memospace/features/library/widgets/filter_sheet.dart';
import 'package:memospace/features/library/widgets/workspace_picker_sheet.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _bottomNavIndex = 1;

  final _searchController = TextEditingController();
  String _query = '';
  String _jenis = 'Semua';
  String _urutan = 'Terbaru';
  bool _termasukArsip = false;
  String? _workspaceId; // null = semua workspace
  String _currentWorkspace = 'Semua workspace';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _jenisOf(Memo m) {
    final f = m.fileName?.toLowerCase();
    if (f == null) return 'Teks';
    if (RegExp(r'\.(jpg|jpeg|png|webp|gif)$').hasMatch(f)) return 'Foto';
    if (RegExp(r'\.(mp4|mov|mkv|webm)$').hasMatch(f)) return 'Video';
    return 'Berkas';
  }

  List<Memo> _applyFilters(List<Memo> all) {
    var list = all.where((m) {
      if (_workspaceId != null && m.workspaceId != _workspaceId) return false;
      if (_jenis != 'Semua' && _jenisOf(m) != _jenis) return false;
      if (!_termasukArsip && m.isArchived) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!m.title.toLowerCase().contains(q) &&
            !m.content.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    if (_urutan == 'Terlama') list = list.reversed.toList();
    if (_urutan == 'Judul A-Z') {
      list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  }

  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final memos = _applyFilters(context.watch<MemoCubit>().state);
    final workspaces = context.watch<WorkspaceCubit>().state;
    final selectedWorkspaceIds = workspaces
        .where((workspace) => workspace.title == _currentWorkspace)
        .map((workspace) => workspace.id)
        .toSet();
    final visibleMemos = _currentWorkspace == 'Semua workspace'
        ? memos
        : memos
            .where((memo) => selectedWorkspaceIds.contains(memo.workspaceId))
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,

      // --- 1. APP BAR ---
      appBar: const MemoAppBar(),

      // --- 2. FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor:
                Colors.transparent, // Mengikuti radius dari container dalam
            isScrollControlled:
                true, // Memungkinkan kustomisasi ukuran yang fleksibel
            builder: (context) {
              return const CreateSheet(); // Memanggil kelas dari create_sheet.dart
            },
          );
        },
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),

      // --- 3. BODY DENGAN SATU PADDING UTAMA MENGAPIT ---
      body: SafeArea(
        child: SingleChildScrollView(
          // PADDING UTAMA DIATUR DI SINI (Menghapus padding parsial di widget-widget dalam)
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TITLE ---
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perpustakaan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Semua catatan dan berkas tersimpan',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- SEARCH BAR ---
              TextField(
                decoration: AppTheme.pillInput(
                  hint: 'Cari di seluruh catatan & berkas...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.black38, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () async {
                      // Panggil Bottom Sheet Filter
                      final dataFilter =
                          await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const FilterSheet(),
                      );

                      if (dataFilter != null) {
                        setState(() {
                          _jenis = dataFilter['jenis'];
                          _urutan = dataFilter['urutan'];
                          _termasukArsip = dataFilter['termasukArsip'];
                        });
                      }
                    },
                  ),
                ),
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 20),

              // --- SUB-FILTER ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      final workspaces = context.read<WorkspaceCubit>().state;
                      final selected =
                          await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => WorkspacePickerSheet(
                          workspaces: workspaces,
                          activeWorkspaceId: _workspaceId,
                        ),
                      );

                      if (selected != null) {
                        setState(() {
                          _workspaceId = selected['id'];
                          _currentWorkspace = selected['title'];
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: Row(
                        children: [
                          Text(
                            _currentWorkspace, // Menggunakan variable dinamis dari state
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary.withOpacity(0.8)),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: AppTheme.textPrimary),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${visibleMemos.length} memo',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isGridView = false;
                          });
                        },
                        icon: Icon(
                          Icons.reorder,
                          size: 20,
                          // Warna hitam pekat jika aktif, abu-abu jika tidak aktif
                          color: !_isGridView
                              ? AppTheme.textPrimary
                              : Colors.black26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isGridView = true; // Ubah ke tampilan Grid
                          });
                        },
                        icon: Icon(
                          Icons.grid_view_outlined,
                          size: 18,
                          // Warna hitam pekat jika aktif, abu-abu jika tidak aktif
                          color: _isGridView
                              ? AppTheme.textPrimary
                              : Colors.black26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),

              // --- LIST CONTENT CARD ---
              if (!_isGridView) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Scroll mengikuti SingleChildScrollView luar
                  itemCount: visibleMemos.length,
                  itemBuilder: (context, index) {
                    final memo = visibleMemos[index];

                    // Membuat inisial user secara otomatis (contoh: Dimas A. -> DA)
                    final words = memo.authorName.split(' ');
                    final initials = words
                        .map((w) => w.isNotEmpty ? w[0] : '')
                        .join()
                        .toUpperCase();

                    return _buildLibraryCard(
                      category: memo.category,
                      badgeText: memo.fileName != null
                          ? memo.fileName!.split('.').last.toUpperCase()
                          : null,
                      title: memo.title,
                      description: memo.content,
                      userInitials: initials.length > 2
                          ? initials.substring(0, 2)
                          : initials,
                      userName: memo.authorName,
                      timeAgo:
                          DateFormatter.getRelativeTimeText(memo.updatedAt),
                      isBookmarked: memo.isBookmarked,
                      // Lampiran dinamis jika ada property fileName
                      attachmentWidget: memo.fileName != null
                          ? _buildPdfAttachment(memo.fileName!)
                          : null,
                    );
                  },
                ),
              ] else ...[
                // --- TAMPILAN GRID VIEW ---
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleMemos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        0.85, // Sesuaikan rasio agar tidak luapan/overflow
                  ),
                  itemBuilder: (context, index) {
                    final memo = visibleMemos[index];
                    return _buildGridLibraryCard(
                      category: memo.category,
                      title: memo.title,
                      description: memo.content,
                      timeAgo:
                          DateFormatter.getRelativeTimeText(memo.updatedAt),
                    );
                  },
                ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPER BUILDER KARTU UTAMA ---
  Widget _buildLibraryCard({
    required String category,
    required String? badgeText,
    required String title,
    required String description,
    required String userInitials,
    required String userName,
    required String timeAgo,
    required bool isBookmarked, // Tambahkan parameter ini
    Widget? attachmentWidget,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(12),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open_outlined,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
              // 💡 Ubah ikon bookmark menjadi dinamis sesuai data dummy
              Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? const Color(0xFF1E1E1E)
                    : AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          if (attachmentWidget != null) ...[
            const SizedBox(height: 12),
            attachmentWidget,
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFFF4F5F7),
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: Colors.black26, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary, size: 16),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER KHUSUS KARTU GRID ---
  Widget _buildGridLibraryCard({
    required String category,
    required String title,
    required String description,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Kategori Singkat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Judul Catatan
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          // Deskripsi Singkat
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 6),
          // Waktu Pembuatan
          Text(
            timeAgo,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK LAMPIRAN PDF ---
  Widget _buildPdfAttachment(String fileName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: Color(0xFF1E1E1E), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName, // 💡 Menjadi dinamis sesuai judul dokumen
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text('Berkas Lampiran',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppTheme.textPrimary, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK LAMPIRAN FOTO ---
  Widget _buildImageAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos', // Ditambahkan ukuran dummy agar tidak error
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos',
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.image_outlined, color: Colors.black38, size: 16),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'uji_kolam_statik_01.jpg • 2 foto (5.8 MB)',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined,
                  color: AppTheme.textPrimary, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        )
      ],
    );
  }
}
