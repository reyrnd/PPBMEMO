import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../home/screens/home_screen.dart';
import '../library/screens/library_screen.dart';
import '../memo/cubit/memo_cubit.dart';
import '../memo/models/memo.dart';
import '../memo/screens/memo_editor_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../workspace/screens/workspace_list_screen.dart';

/// Scope untuk mengontrol tab aktif dari layar mana pun di dalam shell
class MainShellScope extends InheritedWidget {
  final void Function(int) switchTab;

  const MainShellScope({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static MainShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  @override
  bool updateShouldNotify(covariant MainShellScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  late final List<Widget> _pages;
  final Set<String> _seenTeammateMemoIds = <String>{};
  bool _initialSnapshotChecked = false;
  Memo? _topToastMemo;
  Timer? _topToastTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      const HomeScreen(),
      const LibraryScreen(),
      const WorkspaceListScreen(),
      const ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<MemoCubit>().state;
      if (state is MemoLoaded) {
        _checkTeammateMemos(state.memos);
      }
    });
  }

  @override
  void dispose() {
    _topToastTimer?.cancel();
    super.dispose();
  }

  void _checkTeammateMemos(List<Memo> memos) {
    if (memos.isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid ?? 'demo-naya';
    final currentName = (currentUser?.displayName ?? '').trim().toLowerCase();

    final teammateMemos = memos.where((m) {
      final isDifferentUid =
          m.authorId.isNotEmpty && m.authorId != currentUid && m.authorId != 'demo-naya';
      final isDifferentName = m.authorName.trim().isNotEmpty &&
          currentName.isNotEmpty &&
          m.authorName.trim().toLowerCase() != currentName;
      return isDifferentUid || isDifferentName;
    }).toList();

    if (!_initialSnapshotChecked) {
      _initialSnapshotChecked = true;
      for (final m in teammateMemos) {
        _seenTeammateMemoIds.add(m.id);
      }
      if (teammateMemos.isNotEmpty) {
        _showTopToast(teammateMemos.first);
      }
      return;
    }

    for (final m in teammateMemos) {
      if (!_seenTeammateMemoIds.contains(m.id)) {
        _seenTeammateMemoIds.add(m.id);
        _showTopToast(m);
        break;
      }
    }
  }

  void _showTopToast(Memo memo) {
    _topToastTimer?.cancel();
    setState(() => _topToastMemo = memo);
    _topToastTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _topToastMemo = null);
      }
    });
  }

  void _switchTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return BlocListener<MemoCubit, MemoState>(
      listener: (context, state) {
        if (state is MemoLoaded) {
          _checkTeammateMemos(state.memos);
        }
      },
      child: MainShellScope(
        switchTab: _switchTab,
        child: Scaffold(
          backgroundColor: AppTheme.canvas,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 78.0),
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),

              // Top Toast Notification Banner untuk memo baru dari teman
              if (_topToastMemo != null)
                Positioned(
                  top: topPadding + 10,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, child) {
                        return Opacity(
                          opacity: val,
                          child: Transform.translate(
                            offset: Offset(0, (1 - val) * -20),
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          final target = _topToastMemo!;
                          setState(() => _topToastMemo = null);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemoEditorScreen(
                                memoId: target.id,
                                workspaceId: target.workspaceId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.ink,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [AppTheme.shadowCard],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.mint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: AppTheme.olive,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'MEMO BARU DARI TEMAN',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: AppTheme.mint,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_topToastMemo!.authorName.isEmpty ? "Teman tim" : _topToastMemo!.authorName} menambahkan "${_topToastMemo!.title.isEmpty ? "Untitled memo" : _topToastMemo!.title}"',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Buka',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _topToastMemo = null),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Komponen Melayang Navigasi Bawah (Floating Bottom Nav Figma Token)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [AppTheme.shadowNav],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'Home'),
                      _buildNavItem(1, Icons.menu_book_rounded, 'Library'),
                      _buildNavItem(2, Icons.people_alt_rounded, 'Workspace'),
                      _buildNavItem(3, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected ? AppTheme.ink : Colors.white.withOpacity(0.45),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
