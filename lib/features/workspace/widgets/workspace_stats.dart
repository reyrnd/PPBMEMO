import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class WorkspaceStats extends StatelessWidget {
  final String activeMemoCount;
  final String fileCount;
  final String memberCount;

  const WorkspaceStats({
    super.key,
    required this.activeMemoCount,
    required this.fileCount,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(value: activeMemoCount, label: 'Memo Aktif')),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(value: fileCount, label: 'Berkas')),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(value: memberCount, label: 'Anggota Tim')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
