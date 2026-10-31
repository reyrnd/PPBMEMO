import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../home/screens/home_screen.dart';
import '../library/screens/library_screen.dart';
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
  }

  void _switchTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
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
