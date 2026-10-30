import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import '../../memo/models/memo.dart';

class BoardMemoCard extends StatelessWidget {
  final Memo memo;
  final bool compact; // true di kanvas, false di kanban
  final bool isDragging;

  const BoardMemoCard({
    super.key,
    required this.memo,
    this.compact = false,
    this.isDragging = false,
  });

  String get _initials {
    final p =
        memo.authorName.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 168 : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: isDragging
            ? const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (memo.category.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(memo.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            memo.title.isEmpty ? 'Tanpa judul' : memo.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          if (!compact && memo.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(memo.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppTheme.textPrimary,
                child: Text(_initials,
                    style: const TextStyle(fontSize: 8, color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  memo.authorName.isEmpty ? 'Anggota' : memo.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ),
              if (memo.isPinned)
                const Icon(Icons.push_pin,
                    size: 12, color: AppTheme.textPrimary),
            ],
          ),
        ],
      ),
    );
  }
}
