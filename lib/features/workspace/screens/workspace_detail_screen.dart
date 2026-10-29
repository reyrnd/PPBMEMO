import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/avatar_stack.dart';
import 'package:memospace/core/widgets/section_header.dart';
import 'package:memospace/features/activity/data/activity_repository.dart';
import 'package:memospace/features/activity/models/activity.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/data/comment_repository.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';
import 'package:memospace/features/workspace/models/workspace.dart';
import 'package:memospace/features/workspace/models/workspace_member.dart';
import 'package:memospace/features/workspace/board/board_view.dart';
import 'package:memospace/features/workspace/board/canvas_board.dart';
import 'package:memospace/features/workspace/board/kanban_board.dart';
import 'package:memospace/features/workspace/widgets/invite_sheet.dart';
import 'package:memospace/features/workspace/widgets/workspace_menu.dart';
import 'package:memospace/features/workspace/widgets/workspace_stats.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;
  final bool isPinned;
  final bool isOwner;
  final VoidCallback? onTogglePin;
  final VoidCallback? onRenameWorkspace;
  final VoidCallback? onLeaveWorkspace;
  final VoidCallback? onDeleteWorkspace;

  const WorkspaceDetailScreen({
    super.key,
    required this.workspace,
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
  String _urutan = 'Terbaru';
  int _tab = 0;
  late Stream<List<Activity>> _activities;
  final _commentRepository = CommentRepository();
  final Map<String, Stream<int>> _commentCountStreams = {};

  Workspace get _ws => context.watch<WorkspaceCubit>().state.firstWhere(
        (w) => w.id == widget.workspace.id,
        orElse: () => widget.workspace,
      );

  bool get _isOwner => _ws.ownerId == FirebaseAuth.instance.currentUser?.uid;

  Future<void> _renameWorkspace() async {
    final current = context.read<WorkspaceCubit>().state.firstWhere(
          (w) => w.id == widget.workspace.id,
          orElse: () => widget.workspace,
        );
    final controller = TextEditingController(text: current.title);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah nama workspace'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama workspace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == current.title) return;
    if (!mounted) return;
    await context.read<WorkspaceCubit>().rename(widget.workspace.id, newName);
  }

  Future<void> _leaveWorkspace() async {
    final current = context.read<WorkspaceCubit>().state.firstWhere(
          (w) => w.id == widget.workspace.id,
          orElse: () => widget.workspace,
        );
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (current.ownerId == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Pemilik tidak bisa keluar. Hapus workspace jika tidak dipakai lagi.'),
        ),
      );
      return;
    }

    await context.read<WorkspaceCubit>().leave(widget.workspace.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteWorkspace() async {
    await context.read<WorkspaceCubit>().deleteWorkspace(widget.workspace.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _watchActivities();
  }

  @override
  void didUpdateWidget(covariant WorkspaceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace.id != widget.workspace.id ||
        oldWidget.workspace.title != widget.workspace.title) {
      _watchActivities();
    }
  }

  void _watchActivities() {
    _activities = ActivityRepository().watchWorkspaceActivities(
      workspaceId: widget.workspace.id,
      workspaceName: widget.workspace.title,
    );
  }

  Stream<int> _watchCommentCount(String workspaceId, String memoId) =>
      _commentCountStreams.putIfAbsent(
        '$workspaceId/$memoId',
        () => _commentRepository.watchCount(workspaceId, memoId),
      );

  @override
  Widget build(BuildContext context) {
    final workspaceMatches = context
        .watch<WorkspaceCubit>()
        .state
        .where((item) => item.id == widget.workspace.id)
        .toList();
    final workspace =
        workspaceMatches.isEmpty ? widget.workspace : workspaceMatches.first;
    final memos = context
        .watch<MemoCubit>()
        .state
        .where((memo) => memo.workspaceId == workspace.id)
        .toList();
    final latestMemos = memos.toList();
    switch (_urutan) {
      case 'Terlama':
        latestMemos.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'Judul A-Z':
        latestMemos.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      default: // Terbaru, memo yang disematkan di atas
        latestMemos.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }

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
            isPinned: _ws.hasPin,
            isOwner: _isOwner,
            onTogglePin: () =>
                context.read<WorkspaceCubit>().togglePin(widget.workspace.id),
            onRename: _renameWorkspace,
            onLeave: _leaveWorkspace,
            onDelete: _deleteWorkspace,
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
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_border_outlined,
                                size: 14, color: AppTheme.textPrimary),
                            const SizedBox(width: 4),
                            Text(
                              workspace.category.isEmpty
                                  ? 'Workspace'
                                  : workspace.category,
                              style: const TextStyle(
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
                  Text(
                    workspace.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (workspace.description.isNotEmpty)
                    Text(
                      workspace.description,
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
                      _buildAvatarGroup(workspace.members),
                      OutlinedButton(
                        onPressed: () => showInviteSheet(
                          context: context,
                          inviteCode: workspace.inviteCode,
                          members: workspace.members,
                          onSendInvite: (email) => context
                              .read<WorkspaceCubit>()
                              .inviteByEmail(workspace.id, email),
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
              WorkspaceStats(
                activeMemoCount: '${memos.length}',
                fileCount: '${workspace.fileCount}',
                memberCount: '${workspace.members.length}',
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
                          builder: (_) => MemoEditorScreen(
                            workspaceId: widget.workspace.id,
                          ),
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
                SectionHeader(
                  title: _urutan == 'Terbaru' ? 'Memo Terbaru' : 'Semua Memo',
                  badge: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '${memos.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => setState(() => _urutan = v),
                    itemBuilder: (_) => [
                      for (final opt in const [
                        'Terbaru',
                        'Terlama',
                        'Judul A-Z'
                      ])
                        CheckedPopupMenuItem(
                          value: opt,
                          checked: _urutan == opt,
                          child: Text(opt),
                        ),
                    ],
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Urutkan',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            size: 18, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (latestMemos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Belum ada memo di workspace ini.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                else
                  for (final memo in latestMemos)
                    _buildMemoItem(
                      commentsCountStream:
                          _watchCommentCount(memo.workspaceId, memo.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoEditorScreen(
                            workspaceId: memo.workspaceId,
                            memo: memo,
                          ),
                        ),
                      ),
                      isPinned: memo.isPinned,
                      timeAgo:
                          DateFormatter.getRelativeTimeText(memo.updatedAt),
                      title: memo.title,
                      description: memo.content,
                      userInitials: _initials(memo.authorName),
                      userName:
                          memo.authorName.isEmpty ? 'Anggota' : memo.authorName,
                    ),
                const SizedBox(height: 16),
              ] else if (_tab == 1)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: BoardView(
                    canvasBoard: CanvasBoard(memos: memos),
                    kanbanBoard: KanbanBoard(memos: memos),
                    onAddMemo: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MemoEditorScreen(
                                workspaceId: widget.workspace.id,
                              )),
                    ),
                  ),
                )
              else
                StreamBuilder<List<Activity>>(
                  stream: _activities,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Aktivitas gagal dimuat.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final activities = snapshot.data ?? const <Activity>[];
                    if (activities.isEmpty) {
                      return const Text(
                        'Belum ada aktivitas.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      );
                    }
                    return Column(
                      children: [
                        for (final activity in activities)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ActivityRow(activity: activity),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPERS COMPONENT ---
  Widget _buildAvatarGroup(List<WorkspaceMember> members) {
    final initials = members
        .map((member) => member.initials as String)
        .where((value) => value.isNotEmpty)
        .take(5)
        .toList();
    return Row(
      children: [
        if (initials.isNotEmpty) AvatarStack(initials),
        if (initials.isNotEmpty) const SizedBox(width: 8),
        Text('${members.length} anggota',
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
        .toUpperCase();
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
    required VoidCallback onTap,
    required Stream<int> commentsCountStream,
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
  }) {
    return StreamBuilder<int>(
      stream: commentsCountStream,
      initialData: 0,
      builder: (context, snapshot) {
        final commentsCount = snapshot.data;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
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
          ),
        );
      },
    );
  }
}
