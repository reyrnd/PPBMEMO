import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/user_avatar.dart';
import 'package:memospace/features/memo/models/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(comment.initials, 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormatter.getRelativeTimeText(comment.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onReply,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppTheme.textSecondary,
                  ),
                  child: const Text('Balas'),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!comment.isReply) return content;

    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppTheme.border, width: 2),
          ),
        ),
        child: content,
      ),
    );
  }
}
