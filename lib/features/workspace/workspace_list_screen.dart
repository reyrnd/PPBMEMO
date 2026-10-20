import 'package:flutter/material.dart';
import 'package:memospace/features/home/data/dummy_data.dart';
import 'package:memospace/features/workspace/widgets/workspace_card.dart';
import '../../core/app_theme.dart';

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. CUSTOM APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'MemoSpace',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE8F5E9),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'DA',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final w in dummyWorkspaces)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkspaceListScreen(),
                  ),
                ),
                child: WorkspaceCard(workspace: w),
              ),
            ),
        ],
      ),
    );
  }
}
