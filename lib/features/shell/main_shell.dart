import 'package:flutter/material.dart';
import 'package:memospace/features/activity/screens/activity_screen.dart';
import 'package:memospace/features/workspace/screens/workspace_list_screen.dart';
import '../../core/app_theme.dart';
import '../home/screens/home_screen.dart';
import '../library/screens/library_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  List<Widget> get _pages => [
        HomeScreen(
          onSeeAllWorkspaces: () => setState(() => _index = 2),
          onSeeAllMemos: () => setState(() => _index = 1),
          onSeeAllActivities: () => setState(() => _index = 3),
        ),
        const LibraryScreen(),
        const WorkspaceListScreen(),
        const ActivityScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.textPrimary,
        unselectedItemColor: Colors.black38,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              activeIcon: Icon(Icons.folder),
              label: 'Library'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Workspace'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            activeIcon: Icon(Icons.notifications),
            label: 'Aktivitas',
          ),
        ],
      ),
    );
  }
}
