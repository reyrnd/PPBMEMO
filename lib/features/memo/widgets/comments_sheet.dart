import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/app_bottom_sheet.dart';
import 'package:memospace/features/memo/models/comment.dart';
import 'package:memospace/features/memo/widgets/comment_tile.dart';

Future<void> showCommentsSheet({
  required BuildContext context,
  required List<Comment> comments,
  required ValueChanged<String> onSend,
  ValueChanged<Comment>? onReply,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Komentar (${comments.length})',
    heightFactor: 0.7,
    child: _CommentsSheetContent(
      comments: comments,
      onSend: onSend,
      onReply: onReply,
    ),
  );
}

class _CommentsSheetContent extends StatefulWidget {
  final List<Comment> comments;
  final ValueChanged<String> onSend;
  final ValueChanged<Comment>? onReply;

  const _CommentsSheetContent({
    required this.comments,
    required this.onSend,
    this.onReply,
  });

  @override
  State<_CommentsSheetContent> createState() => _CommentsSheetContentState();
}

class _CommentsSheetContentState extends State<_CommentsSheetContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.comments.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada komentar.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: widget.comments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = widget.comments[index];
                    return CommentTile(
                      comment: comment,
                      onReply: widget.onReply == null
                          ? null
                          : () => widget.onReply!(comment),
                    );
                  },
                ),
        ),
        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: AppTheme.editorToolbarBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Kirim komentar',
              onPressed: _send,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                fixedSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.send, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
