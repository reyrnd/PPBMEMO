import 'package:flutter/material.dart';
import 'package:memospace/features/memo/models/comment.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:memospace/features/memo/widgets/comments_sheet.dart';
import 'package:memospace/features/memo/widgets/editor_toolbar.dart';
import '../../../core/app_theme.dart';

class MemoEditorScreen extends StatefulWidget {
  const MemoEditorScreen({super.key});

  @override
  State<MemoEditorScreen> createState() => _MemoEditorScreenState();
}

class _MemoEditorScreenState extends State<MemoEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<Comment> _comments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _openComments() {
    showCommentsSheet(
      context: context,
      comments: List.unmodifiable(_comments),
      onSend: (text) {
        setState(() {
          _comments.add(
            Comment(
              id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
              memoId: 'new-memo',
              authorName: 'Saya',
              initials: 'SY',
              text: text,
              createdAt: DateTime.now(),
            ),
          );
        });
      },
    );
  }

  void _saveMemo() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis judul atau isi memo terlebih dahulu.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      Memo(
        id: 'memo-${DateTime.now().microsecondsSinceEpoch}',
        category: 'Proyek Robot AUV',
        title: title.isEmpty ? 'Memo tanpa judul' : title,
        content: content,
        author: 'Saya',
        time: 'Baru saja',
        isPinned: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // --- 1. APP BAR UTAMA ---
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editor Catatan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.textPrimary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- AREA SCROLLABLE KONTEN ---
            Expanded(
              child: SingleChildScrollView(
                // Menggunakan padding standar projek Anda
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 2. SUB-BAR (STATUS SIMPAN & AVATAR EDITORS) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 6, color: Color(0xFF22C55E)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Draft lokal',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Buka komentar',
                              onPressed: _openComments,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: AppTheme.textPrimary,
                                    size: 22,
                                  ),
                                  if (_comments.isNotEmpty)
                                    Positioned(
                                      right: -6,
                                      top: -6,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 14,
                                          minHeight: 14,
                                        ),
                                        child: Text(
                                          '${_comments.length}',
                                          style: const TextStyle(
                                            color: AppTheme.background,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.more_vert,
                                color: AppTheme.textPrimary, size: 22),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 3. BADGE WORKSPACE SELECTOR ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open,
                              size: 14, color: AppTheme.textSecondary),
                          SizedBox(width: 6),
                          Text('Proyek Robot AUV',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              size: 14, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 4. JUDUL & SUBTITLE EDITOR ---
                    TextField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Judul memo',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Memo baru',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // --- 5. ISI CATATAN TEKS ---
                    TextField(
                      controller: _contentController,
                      minLines: 12,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Mulai tulis memo...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- 8. BOTTOM TOOLBAR (DOCK BOTTOM STICKY) ---
            EditorToolbar(
              onPhoto: () {},
              onVideo: () {},
              onFile: () {},
              onChecklist: () {},
              onSave: _saveMemo,
            ),
          ],
        ),
      ),
    );
  }
}
