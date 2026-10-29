import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/app_bottom_sheet.dart';
import 'package:memospace/features/memo/models/comment.dart';
import 'package:memospace/features/memo/widgets/comment_tile.dart';

Future<void> showCommentsSheet({
  required BuildContext context,
  required Stream<List<Comment>> comments,
  required Future<void> Function(String) onSend,
  ValueChanged<Comment>? onReply,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Komentar',
    heightFactor: 0.7,
    child: _CommentsSheetContent(
      comments: comments,
      onSend: onSend,
      onReply: onReply,
    ),
  );
}

class _CommentsSheetContent extends StatefulWidget {
  final Stream<List<Comment>> comments;
  final Future<void> Function(String) onSend;
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
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await widget.onSend(text);
      _controller.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar gagal dikirim.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: widget.comments,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Komentar gagal dimuat.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data ?? const <Comment>[];
              if (comments.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada komentar.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentTile(
                    comment: comment,
                    onReply: widget.onReply == null
                        ? null
                        : () => widget.onReply!(comment),
                  );
                },
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
              onPressed: _isSending ? null : _send,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                fixedSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.background,
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
