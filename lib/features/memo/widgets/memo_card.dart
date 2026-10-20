import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../models/memo.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  const MemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(memo.category,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ),
              Icon(
                memo.isPinned
                    ? Icons.push_pin
                    : (memo.isBookmarked
                        ? Icons.bookmark_border
                        : Icons.more_horiz),
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(memo.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(memo.content,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          if (memo.fileName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 14, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(memo.fileName!,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (memo.taskCount != null) ...[
            Row(
              children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(memo.taskCount!,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(memo.author,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('•  ${memo.time}',
                  style: const TextStyle(fontSize: 12, color: Colors.black38)),
            ],
          ),
        ],
      ),
    );
  }
}
