import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/avatar_stack.dart';
import 'package:memospace/core/widgets/section_header.dart';
import 'package:memospace/features/activity/data/dummy_activities.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/memo/data/dummy_memos.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/board/board_view.dart';
import 'package:memospace/features/workspace/board/canvas_board.dart';
import 'package:memospace/features/workspace/board/kanban_board.dart';
import 'package:memospace/features/workspace/models/workspace_member.dart';
import 'package:memospace/features/workspace/widgets/invite_sheet.dart';
import 'package:memospace/features/workspace/widgets/workspace_menu.dart';
import 'package:memospace/features/workspace/widgets/workspace_stats.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final bool isPinned;
  final bool isOwner;
  final VoidCallback? onTogglePin;
  final VoidCallback? onRenameWorkspace;
  final VoidCallback? onLeaveWorkspace;
  final VoidCallback? onDeleteWorkspace;

  const WorkspaceDetailScreen({
    super.key,
    this.isPinned = false,
    this.isOwner = false,
    this.onTogglePin,
    this.onRenameWorkspace,
    this.onLeaveWorkspace,
    this.onDeleteWorkspace,
  });

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // --- 1. APP BAR ---
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Workspace Detail',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          WorkspaceMenu(
            isPinned: widget.isPinned,
            isOwner: widget.isOwner,
            onTogglePin: widget.onTogglePin,
            onRename: widget.onRenameWorkspace,
            onLeave: widget.onLeaveWorkspace,
            onDelete: widget.onDeleteWorkspace,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary,
              child: Icon(
                Icons.person_outline,
                color: AppTheme.background,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // --- ATURAN PADDING UTAMA YANG SERAGAM DENGAN FILE LAIN ---
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. HEADER INFO & TITLE ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori & Status Sinkronisasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.editorToolbarBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bookmark_border_outlined,
                                size: 14, color: AppTheme.textPrimary),
                            SizedBox(width: 4),
                            Text(
                              'Robotika & Elektro',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
                          SizedBox(width: 6),
                          Text(
                            'Sinkron otomatis',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Judul Workspace
                  const Text(
                    'Proyek Robot AUV',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tempat kolaborasi dan dokumentasi teknis tim robot bawah air mandiri.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Anggota Tim & Tombol Undang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAvatarGroup(),
                      OutlinedButton(
                        onPressed: () => showInviteSheet(
                          context: context,
                          inviteCode: '123456',
                          members: const [
                            WorkspaceMember(
                              userId: 'auv-dina',
                              name: 'Dina Novita',
                              initials: 'DN',
                              role: MemberRole.owner,
                            ),
                            WorkspaceMember(
                              userId: 'auv-budi',
                              name: 'Budi Santoso',
                              initials: 'BS',
                              role: MemberRole.member,
                            ),
                            WorkspaceMember(
                              userId: 'auv-andi',
                              name: 'Andi Firmansyah',
                              initials: 'AF',
                              role: MemberRole.member,
                            ),
                            WorkspaceMember(
                              userId: 'auv-rani',
                              name: 'Rani Nurdin',
                              initials: 'RN',
                              role: MemberRole.member,
                            ),
                            WorkspaceMember(
                              userId: 'auv-miko',
                              name: 'Miko Kurniawan',
                              initials: 'MK',
                              role: MemberRole.member,
                            ),
                            WorkspaceMember(
                              userId: 'auv-farhan',
                              name: 'Farhan Kurniawan',
                              initials: 'FK',
                              role: MemberRole.member,
                            ),
                          ],
                          onSendInvite: (email) async {},
                          onShareInvite: (inviteCode) async {
                            await Clipboard.setData(
                              ClipboardData(text: inviteCode),
                            );
                          },
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppTheme.editorToolbarBackground,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        child: const Text(
                          '+ Undang',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- 3. METRICS CARDS ROW ---
              const WorkspaceStats(
                activeMemoCount: '18',
                fileCount: '6',
                memberCount: '6',
              ),

              const SizedBox(height: 20),

              // --- 4. ACTION BUTTONS ROW ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MemoEditorScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Buat Memo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.editorToolbarBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search,
                          size: 22, color: AppTheme.textPrimary),
                      onPressed: () {},
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // --- 5. SUB-TAB SEGMENT (PILL MENU) ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.editorToolbarBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildSubTab('Library', 0)),
                    Expanded(child: _buildSubTab('Kanvas', 1)),
                    Expanded(child: _buildSubTab('Aktivitas', 2)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_tab == 0) ...[
                // SectionHeader "Memo Terbaru" + tiga _buildMemoItem(...) yang sudah ada
                // --- 6. SECTION HEADER: MEMO TERBARU ---
                SectionHeader(
                  title: 'Memo Terbaru',
                  badge: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.editorToolbarBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '18',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  actionLabel: 'Urutkan',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                // KARTU MEMO 1 (Pinned / Disematkan)
                _buildMemoItem(
                  isPinned: true,
                  timeAgo: '1 jam lalu',
                  title: 'Catatan Rapat Tim: Pembagian Modul',
                  description:
                      'Pembagian tugas pengerjaan subsistem sonar, kontrol PID propulsi, dan integrasi ROS 2 Humble...',
                  hasAttachment: true,
                  attachmentName: 'Notulensi_Sprint_AUV_v1.pdf',
                  attachmentSize: '1.2 MB',
                  userInitials: 'DN',
                  userName: 'Dina Novita',
                  commentsCount: 4,
                ),
                // KARTU MEMO 2 (Dengan Hashtags)
                _buildMemoItem(
                  isPinned: false,
                  timeAgo: 'Kemarin',
                  title: 'Hasil Uji Baterai LiPo 4S 5000mAh',
                  description:
                      'Penurunan tegangan pada beban 4 thruster maksimal 14.2V setelah 25 menit pengujian...',
                  tags: ['#Baterai', '#Hardware'],
                  userInitials: 'BS',
                  userName: 'Budi Santoso',
                  commentsCount: 2,
                ),
                // KARTU MEMO 3 (Dengan Progress Bar)
                _buildMemoItem(
                  isPinned: false,
                  timeAgo: '3 hari lalu',
                  title: 'Daftar Komponen Cadangan Kontes AUV',
                  description:
                      'Sensor cadangan IMU BNO055 dan thruster T200 telah masuk inventaris lab, menunggu pengiriman',
                  tags: ['#Logistik', '#Kontes'],
                  progressText: '8/10 terkumpul',
                  progressValue: 0.8,
                  userInitials: 'FK',
                  userName: 'Farhan Kurniawan',
                  commentsCount: 7,
                ),
                const SizedBox(height: 16),
              ] else if (_tab == 1)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: BoardView(
                    canvasBoard: CanvasBoard(memos: dummyMemos),
                    kanbanBoard: KanbanBoard(memos: dummyMemos),
                    onAddMemo: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MemoEditorScreen()),
                    ),
                  ),
                )
              else ...[
                for (final a in dummyActivities) ActivityRow(activity: a),
              ],
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPERS COMPONENT ---
  Widget _buildAvatarGroup() {
    return const Row(
      children: [
        AvatarStack(['DN', 'BS', 'AF', 'RN', 'MK', 'FK']),
        SizedBox(width: 8),
        Text('6 aktif',
            style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSubTab(String text, int index) {
    final isActive = _tab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
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
    required String userInitials,
    required String userName,
    int? commentsCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPinned)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.editorToolbarBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Disematkan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (tags != null)
                Row(
                  children: tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.editorToolbarBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const SizedBox.shrink(),
              const Icon(Icons.bookmark_border,
                  color: AppTheme.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3),
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kesiapan Komponen',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(
                  progressText ?? '',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: const Color(0xFFDCFCE7),
                color: const Color(0xFF22C55E),
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          if (hasAttachment && attachmentName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.editorToolbarBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf,
                      color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attachmentName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(attachmentSize ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            )
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: userInitials == 'DN'
                        ? AppTheme.textPrimary
                        : (userInitials == 'BS'
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF374151)),
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  Text(' • $timeAgo',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${commentsCount ?? 0}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
