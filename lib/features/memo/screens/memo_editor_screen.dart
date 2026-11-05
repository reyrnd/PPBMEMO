import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/attachment_picker.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../workspace/cubit/workspace_cubit.dart';
import '../../workspace/models/workspace.dart';
import '../cubit/memo_cubit.dart';
import '../data/comment_repository.dart';
import '../models/comment.dart';
import '../models/memo.dart';

/// Custom WYSIWYG TextEditingController yang merender format Bold, Italic,
/// Bold+Italic, Bullet (• ), Quote (> ), dan Link secara langsung TANPA
/// menampilkan simbol * atau _ di dalam editor.
class RichMemoTextEditingController extends TextEditingController {
  static const int styleNone = 0;
  static const int styleBold = 1;
  static const int styleItalic = 2;

  List<int> _charStyles = [];
  String _lastSyncedText = '';
  int activeTypingStyle = styleNone;

  RichMemoTextEditingController({String? text}) : super(text: '') {
    if (text != null && text.isNotEmpty) {
      loadFormattedContent(text);
    }
  }

  /// Memuat teks yang mungkin memiliki penanda markdown (**bold**, _italic_, ***bolditalic***)
  /// dan mengubahnya menjadi teks bersih tanpa simbol * atau _ beserta array style per karakter.
  void loadFormattedContent(String raw) {
    final buffer = StringBuffer();
    final styles = <int>[];

    final tokenRegex = RegExp(
      r'(\*\*\*[^*\n]+\*\*\*)|(⸻B_I⸻)|(_\*\*[^*\n]+\*\*_)|(\*\*_[^_\n]+_\*\*)|(\*\*[^*\n]+\*\*)|(_[^_\n]+_)',
    );

    int index = 0;
    for (final match in tokenRegex.allMatches(raw)) {
      if (match.start > index) {
        final plain = raw.substring(index, match.start);
        buffer.write(plain);
        for (int i = 0; i < plain.length; i++) {
          styles.add(styleNone);
        }
      }

      final token = match.group(0)!;
      String inner = token;
      int tokenStyle = styleNone;

      if ((token.startsWith('***') && token.endsWith('***')) ||
          (token.startsWith('_**') && token.endsWith('**_')) ||
          (token.startsWith('**_') && token.endsWith('_**'))) {
        inner = token.substring(3, token.length - 3);
        tokenStyle = styleBold | styleItalic;
      } else if (token.startsWith('**') && token.endsWith('**')) {
        inner = token.substring(2, token.length - 2);
        tokenStyle = styleBold;
      } else if (token.startsWith('_') && token.endsWith('_')) {
        inner = token.substring(1, token.length - 1);
        tokenStyle = styleItalic;
      }

      buffer.write(inner);
      for (int i = 0; i < inner.length; i++) {
        styles.add(tokenStyle);
      }

      index = match.end;
    }

    if (index < raw.length) {
      final tail = raw.substring(index);
      buffer.write(tail);
      for (int i = 0; i < tail.length; i++) {
        styles.add(styleNone);
      }
    }

    final clean = buffer.toString();
    _charStyles = styles;
    _lastSyncedText = clean;
    value = TextEditingValue(
      text: clean,
      selection: TextSelection.collapsed(offset: clean.length),
    );
  }

  /// Mengekspor teks beserta style ke format penyimpanan agar saat dibuka kembali tetap terjaga
  String exportFormattedContent() {
    _syncStylesWithText(text);
    if (text.isEmpty) return '';
    final out = StringBuffer();
    int i = 0;
    while (i < text.length) {
      if (text[i] == '\n') {
        out.write('\n');
        i++;
        continue;
      }
      final currentStyle = _charStyles[i];
      int j = i + 1;
      while (j < text.length &&
          text[j] != '\n' &&
          _charStyles[j] == currentStyle) {
        j++;
      }
      final segment = text.substring(i, j);
      if (currentStyle == (styleBold | styleItalic)) {
        out.write('***$segment***');
      } else if (currentStyle == styleBold) {
        out.write('**$segment**');
      } else if (currentStyle == styleItalic) {
        out.write('_${segment}_');
      } else {
        out.write(segment);
      }
      i = j;
    }
    return out.toString();
  }

  /// Sinkronisasi panjang `_charStyles` saat user mengetik atau menghapus karakter
  void _syncStylesWithText(String currentText) {
    if (currentText == _lastSyncedText &&
        _charStyles.length == currentText.length) {
      return;
    }

    final oldText = _lastSyncedText;
    final oldStyles = List<int>.from(_charStyles);

    int prefix = 0;
    while (prefix < oldText.length &&
        prefix < currentText.length &&
        oldText[prefix] == currentText[prefix]) {
      prefix++;
    }

    int oldSuffix = oldText.length;
    int newSuffix = currentText.length;
    while (oldSuffix > prefix &&
        newSuffix > prefix &&
        oldText[oldSuffix - 1] == currentText[newSuffix - 1]) {
      oldSuffix--;
      newSuffix--;
    }

    final updatedStyles = <int>[];
    for (int i = 0; i < prefix; i++) {
      updatedStyles.add(i < oldStyles.length ? oldStyles[i] : styleNone);
    }

    final insertedCount = newSuffix - prefix;
    final inheritedStyle = activeTypingStyle != styleNone
        ? activeTypingStyle
        : (prefix > 0 && prefix - 1 < oldStyles.length
            ? oldStyles[prefix - 1]
            : styleNone);

    for (int i = 0; i < insertedCount; i++) {
      final char = currentText[prefix + i];
      updatedStyles.add(char == '\n' ? styleNone : inheritedStyle);
    }

    for (int i = oldSuffix; i < oldText.length; i++) {
      updatedStyles.add(i < oldStyles.length ? oldStyles[i] : styleNone);
    }

    _charStyles = updatedStyles;
    _lastSyncedText = currentText;
  }

  /// Cek apakah style bit (`styleBold` / `styleItalic`) aktif di seleksi atau kursor saat ini
  bool isStyleBitActive(int styleBit) {
    _syncStylesWithText(text);
    final sel = selection;
    if (!sel.isValid) return (activeTypingStyle & styleBit) != 0;

    final start = sel.start.clamp(0, text.length);
    final end = sel.end.clamp(0, text.length);

    if (start != end) {
      for (int i = start; i < end; i++) {
        if (text[i] != '\n' && (_charStyles[i] & styleBit) == 0) {
          return false;
        }
      }
      return true;
    }

    if (start > 0 && start <= _charStyles.length) {
      return (_charStyles[start - 1] & styleBit) != 0 ||
          (activeTypingStyle & styleBit) != 0;
    }
    return (activeTypingStyle & styleBit) != 0;
  }

  /// Toggle Bold atau Italic pada teks yang diblok tanpa menambahkan karakter * atau _
  void toggleStyleBit(int styleBit) {
    _syncStylesWithText(text);
    final sel = selection;
    final start = sel.isValid ? sel.start.clamp(0, text.length) : text.length;
    final end = sel.isValid ? sel.end.clamp(0, text.length) : text.length;

    if (start != end) {
      final currentlyAllActive = isStyleBitActive(styleBit);
      for (int i = start; i < end; i++) {
        if (text[i] == '\n') continue;
        if (currentlyAllActive) {
          _charStyles[i] &= ~styleBit;
        } else {
          _charStyles[i] |= styleBit;
        }
      }
      activeTypingStyle = currentlyAllActive
          ? (activeTypingStyle & ~styleBit)
          : (activeTypingStyle | styleBit);
      notifyListeners();
    } else {
      if ((activeTypingStyle & styleBit) != 0) {
        activeTypingStyle &= ~styleBit;
      } else {
        activeTypingStyle |= styleBit;
      }
      notifyListeners();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ??
        const TextStyle(
          fontSize: 13,
          color: AppTheme.muted,
          height: 1.75,
          fontWeight: FontWeight.w500,
        );

    final rawText = text;
    if (rawText.isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }

    _syncStylesWithText(rawText);

    final lines = rawText.split('\n');
    final lineSpans = <InlineSpan>[];
    int globalOffset = 0;

    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final line = lines[lineIdx];
      TextStyle lineBaseStyle = baseStyle;

      if (line.startsWith('> ')) {
        lineBaseStyle = baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: AppTheme.olive,
          fontWeight: FontWeight.w600,
        );
      } else if (line.startsWith('• ')) {
        lineBaseStyle = baseStyle.copyWith(
          color: AppTheme.ink,
        );
      }

      lineSpans.addAll(
        _buildStyledLineSpans(line, globalOffset, lineBaseStyle),
      );
      globalOffset += line.length;

      if (lineIdx < lines.length - 1) {
        lineSpans.add(TextSpan(text: '\n', style: baseStyle));
        globalOffset += 1; // newline char
      }
    }

    return TextSpan(style: baseStyle, children: lineSpans);
  }

  List<InlineSpan> _buildStyledLineSpans(
    String line,
    int lineStartOffset,
    TextStyle lineBaseStyle,
  ) {
    if (line.isEmpty) return const [];

    final spans = <InlineSpan>[];
    final linkPattern = RegExp(r'(\[[^\]]+\]\([^)]+\))|(https?://\S+)');
    final linkRanges = <RegExpMatch>[
      ...linkPattern.allMatches(line),
    ];

    int i = 0;
    while (i < line.length) {
      RegExpMatch? activeLink;
      for (final m in linkRanges) {
        if (i >= m.start && i < m.end) {
          activeLink = m;
          break;
        }
      }

      if (activeLink != null) {
        final token = activeLink.group(0)!;
        spans.add(
          TextSpan(
            text: token,
            style: lineBaseStyle.copyWith(
              color: AppTheme.plum,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        );
        i = activeLink.end;
        continue;
      }

      final absIdx = lineStartOffset + i;
      final styleBits =
          absIdx < _charStyles.length ? _charStyles[absIdx] : styleNone;

      int j = i + 1;
      while (j < line.length) {
        final hitsLink = linkRanges.any((m) => j >= m.start && j < m.end);
        if (hitsLink) break;
        final nextAbs = lineStartOffset + j;
        final nextBits =
            nextAbs < _charStyles.length ? _charStyles[nextAbs] : styleNone;
        if (nextBits != styleBits) break;
        j++;
      }

      final chunk = line.substring(i, j);
      final isBold = (styleBits & styleBold) != 0;
      final isItalic = (styleBits & styleItalic) != 0;

      TextStyle chunkStyle = lineBaseStyle;
      if (isBold || isItalic) {
        chunkStyle = chunkStyle.copyWith(
          fontWeight: isBold ? FontWeight.w800 : chunkStyle.fontWeight,
          fontStyle: isItalic ? FontStyle.italic : chunkStyle.fontStyle,
          color: AppTheme.ink,
        );
      }

      spans.add(TextSpan(text: chunk, style: chunkStyle));
      i = j;
    }

    return spans;
  }
}

class MemoEditorScreen extends StatefulWidget {
  final String? memoId;
  final String? workspaceId;
  final bool initialIsChecklist;
  final String? initialTitle;
  final String? initialContent;

  const MemoEditorScreen({
    super.key,
    this.memoId,
    this.workspaceId,
    this.initialIsChecklist = false,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<MemoEditorScreen> createState() => _MemoEditorScreenState();
}

class _MemoEditorScreenState extends State<MemoEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final RichMemoTextEditingController _contentController =
      RichMemoTextEditingController();
  final TextEditingController _checklistTitleController =
      TextEditingController();
  final TextEditingController _checklistController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final CommentRepository _commentRepo = CommentRepository();

  bool _isDirty = false;
  bool _canEdit = true;
  bool _isSaving = false;
  String? _activeMemoId;
  String? _activeWorkspaceId;
  String _currentTag = 'Personal';
  String _currentDueDate = '';
  String _savedAtText = 'Saved 18 min ago';
  String _authorName = 'Naya Anindita';
  String _previousContentText = '';

  int? _editingChecklistIndex;
  final TextEditingController _editChecklistTextController =
      TextEditingController();

  String? _replyingToCommentId;
  String? _replyingToAuthorName;

  final List<Map<String, dynamic>> _attachments = [];
  final List<Map<String, dynamic>> _checklistItems = [];
  final List<Comment> _localComments = [];

  /// True jika user sedang membuat memo baru (belum disimpan pertama kali)
  bool get _isCreating => _activeMemoId == null;

  @override
  void initState() {
    super.initState();
    _activeMemoId = widget.memoId;
    _activeWorkspaceId = widget.workspaceId;

    final workspaces = context.read<WorkspaceCubit>().state;
    if (_activeWorkspaceId == null && workspaces.isNotEmpty) {
      _activeWorkspaceId = workspaces.first.id;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid ?? 'demo-naya';

    if (_activeMemoId != null) {
      final memoState = context.read<MemoCubit>().state;
      Memo? matchedMemo;
      if (memoState is MemoLoaded) {
        final matches =
            memoState.memos.where((memo) => memo.id == _activeMemoId);
        if (matches.isNotEmpty) {
          matchedMemo = matches.first;
        }
      }

      if (matchedMemo != null) {
        _titleController.text = matchedMemo.title;
        _contentController.loadFormattedContent(matchedMemo.content);
        _previousContentText = _contentController.text;
        _checklistTitleController.text = matchedMemo.checklistTitle;
        _currentTag = matchedMemo.tag.isEmpty ? 'Personal' : matchedMemo.tag;
        _currentDueDate = matchedMemo.dueDate;
        if (matchedMemo.workspaceId.isNotEmpty) {
          _activeWorkspaceId = matchedMemo.workspaceId;
        }
        _savedAtText =
            matchedMemo.meta.isEmpty ? 'Saved recently' : matchedMemo.meta;
        // Kepemilikan memo: hanya pemilik yang bisa mengedit
        _canEdit = matchedMemo.authorId.isEmpty ||
            matchedMemo.authorId == currentUid ||
            (currentUser == null && matchedMemo.authorId == 'demo-naya');

        if (_canEdit &&
            currentUser?.displayName != null &&
            currentUser!.displayName!.trim().isNotEmpty) {
          _authorName = currentUser.displayName!.trim();
        } else {
          _authorName = matchedMemo.authorName.isEmpty
              ? 'Workspace member'
              : matchedMemo.authorName;
        }

        if (matchedMemo.attachments.isNotEmpty) {
          _attachments.addAll(
            matchedMemo.attachments.map((e) => Map<String, dynamic>.from(e)),
          );
        }
        if (matchedMemo.checklist.isNotEmpty) {
          _checklistItems.addAll(
            matchedMemo.checklist.map((e) => Map<String, dynamic>.from(e)),
          );
        }
      } else {
        _titleController.text = widget.initialTitle ?? '';
        _contentController.loadFormattedContent(widget.initialContent ?? '');
        _previousContentText = _contentController.text;
        _canEdit = true;
      }
    } else {
      _canEdit = true;
      _savedAtText = 'Draft';
      if (widget.initialTitle != null) {
        _titleController.text = widget.initialTitle!;
      }
      if (widget.initialContent != null) {
        _contentController.loadFormattedContent(widget.initialContent!);
        _previousContentText = _contentController.text;
      }
      if (widget.initialIsChecklist) {
        _currentTag = 'Checklist';
        _checklistTitleController.text = 'Action items';
        _checklistItems.add({
          'id': 'check-init',
          'text': 'First checklist item',
          'done': false,
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _checklistTitleController.dispose();
    _checklistController.dispose();
    _commentController.dispose();
    _replyController.dispose();
    _editChecklistTextController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Workspace? _resolveActiveWorkspace(List<Workspace> workspaces) {
    if (workspaces.isEmpty) return null;
    if (_activeWorkspaceId == null) return workspaces.first;
    final found = workspaces.where((w) => w.id == _activeWorkspaceId);
    return found.isNotEmpty ? found.first : workspaces.first;
  }

  /// Menampilkan bottom sheet pemilihan workspace tujuan untuk memo ini
  void _showWorkspaceSelectorSheet() {
    if (!_canEdit) return;
    final workspaces = context.read<WorkspaceCubit>().state;
    final memoState = context.read<MemoCubit>().state;
    final allMemos = memoState is MemoLoaded ? memoState.memos : <Memo>[];
    if (workspaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workspaces available. Create a workspace first.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: 'Choose workspace',
        description: 'Select which workspace this memo belongs to.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: workspaces.map((ws) {
            final isSelected = ws.id == _activeWorkspaceId;
            final liveMemoCount =
                allMemos.where((m) => m.workspaceId == ws.id).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _activeWorkspaceId = ws.id;
                      _currentTag = ws.name;
                      _isDirty = true;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.ink : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.ink : AppTheme.mint,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 17,
                            color: isSelected ? Colors.white : AppTheme.olive,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ws.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ws.members.isEmpty ? 1 : ws.members.length} members · $liveMemoCount memos',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.faint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppTheme.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _saveDocument({bool closeAfterCreate = false}) async {
    if (!_canEdit || _isSaving) return;
    final trimmedTitle = _titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi judul memo terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final workspaces = context.read<WorkspaceCubit>().state;
    final workspaceId = _activeWorkspaceId ??
        (workspaces.isNotEmpty ? workspaces.first.id : 'personal-space');
    final activeWorkspace = _resolveActiveWorkspace(workspaces);

    // Tentukan tag yang deskriptif untuk Library
    String resolvedTag = _currentTag;
    if (resolvedTag.isEmpty || resolvedTag == 'Personal') {
      if (_attachments.any(
          (a) => a['type'] == 'Photo' || a['type'] == 'Video')) {
        resolvedTag = 'Media';
      } else if (_attachments.any(
          (a) => a['type'] == 'PDF' || a['type'] == 'Document')) {
        resolvedTag = 'Files';
      } else if (_checklistItems.isNotEmpty) {
        resolvedTag = 'Projects';
      } else if (activeWorkspace != null && activeWorkspace.name.isNotEmpty) {
        resolvedTag = activeWorkspace.name;
      } else {
        resolvedTag = 'Ideas';
      }
    }

    try {
      final serializedContent = _contentController.exportFormattedContent();
      final wasCreating = _activeMemoId == null;
      if (wasCreating) {
        final newId = await context.read<MemoCubit>().addMemo(
              workspaceId: workspaceId,
              title: trimmedTitle,
              content: serializedContent,
              tag: resolvedTag,
              dueDate: _currentDueDate,
              checklistTitle: _checklistTitleController.text.trim(),
              attachments: List<Map<String, dynamic>>.from(_attachments),
              checklist: List<Map<String, dynamic>>.from(_checklistItems),
            );
        if (!mounted) return;
        setState(() {
          _activeMemoId = newId;
          _activeWorkspaceId = workspaceId;
          _isDirty = false;
          _isSaving = false;
          _savedAtText = 'Saved just now';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memo berhasil dibuat!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        if (closeAfterCreate && mounted) {
          Navigator.pop(context);
        }
      } else {
        await context.read<MemoCubit>().updateMemo(
              workspaceId,
              _activeMemoId!,
              trimmedTitle,
              serializedContent,
              tag: resolvedTag,
              dueDate: _currentDueDate,
              checklistTitle: _checklistTitleController.text.trim(),
              attachments: List<Map<String, dynamic>>.from(_attachments),
              checklist: List<Map<String, dynamic>>.from(_checklistItems),
            );
        if (!mounted) return;
        setState(() {
          _isDirty = false;
          _isSaving = false;
          _savedAtText = 'Saved just now';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan memo disimpan'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan memo: $e')),
      );
    }
  }

  /// Auto-continue bullet list ketika user menekan Enter setelah baris '• '
  void _handleContentChanged(String newValue) {
    if (newValue.length == _previousContentText.length + 1 &&
        newValue.endsWith('\n')) {
      final cursor = _contentController.selection.baseOffset;
      if (cursor > 1) {
        final beforeNewline = newValue.substring(0, cursor - 1);
        final lastLineStart = beforeNewline.lastIndexOf('\n') + 1;
        final prevLine = beforeNewline.substring(lastLineStart);

        if (prevLine.startsWith('• ') && prevLine.trim() != '•') {
          final updated =
              '${newValue.substring(0, cursor)}• ${newValue.substring(cursor)}';
          _previousContentText = updated;
          _contentController.value = TextEditingValue(
            text: updated,
            selection: TextSelection.collapsed(offset: cursor + 2),
          );
          if (!_isDirty) setState(() => _isDirty = true);
          return;
        }
      }
    }

    _previousContentText = newValue;
    if (!_isDirty) {
      setState(() => _isDirty = true);
    } else {
      setState(() {});
    }
  }

  /// Cek apakah kursor/seleksi saat ini berada di dalam format tertentu
  bool _isFormatActive(String format) {
    final text = _contentController.text;
    final sel = _contentController.selection;

    if (format == 'Bold') {
      return _contentController.isStyleBitActive(
        RichMemoTextEditingController.styleBold,
      );
    }
    if (format == 'Italic') {
      return _contentController.isStyleBitActive(
        RichMemoTextEditingController.styleItalic,
      );
    }

    if (!sel.isValid || text.isEmpty) return false;
    final start = sel.start.clamp(0, text.length);

    if (format == 'Bullet list') {
      final lineStart = text.lastIndexOf('\n', start > 0 ? start - 1 : 0) + 1;
      return text.substring(lineStart).startsWith('• ');
    }
    if (format == 'Quote') {
      final lineStart = text.lastIndexOf('\n', start > 0 ? start - 1 : 0) + 1;
      return text.substring(lineStart).startsWith('> ');
    }
    return false;
  }

  /// Menerapkan pemformatan teks (Bold, Italic, Bullet list, Quote, Link)
  /// secara WYSIWYG tanpa menampilkan simbol * atau _ di dalam editor.
  void _applyFormatting(String format) {
    if (!_canEdit) return;

    if (format == 'Link') {
      _showInsertLinkSheet();
      return;
    }

    if (format == 'Bold') {
      _contentController.toggleStyleBit(RichMemoTextEditingController.styleBold);
      _contentFocusNode.requestFocus();
      setState(() => _isDirty = true);
      return;
    }

    if (format == 'Italic') {
      _contentController
          .toggleStyleBit(RichMemoTextEditingController.styleItalic);
      _contentFocusNode.requestFocus();
      setState(() => _isDirty = true);
      return;
    }

    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    if (format == 'Bullet list' || format == 'Quote') {
      final prefix = format == 'Bullet list' ? '• ' : '> ';
      final altPrefix = format == 'Bullet list' ? '> ' : '• ';

      final lineStart =
          start > 0 ? text.lastIndexOf('\n', start - 1) + 1 : 0;
      final lineEndIdx = text.indexOf('\n', end);
      final lineEnd = lineEndIdx == -1 ? text.length : lineEndIdx;
      final currentBlock = text.substring(lineStart, lineEnd);

      final blockLines = currentBlock.split('\n');
      final allHavePrefix =
          blockLines.every((l) => l.startsWith(prefix));

      final transformedLines = blockLines.map((l) {
        if (allHavePrefix) {
          return l.substring(prefix.length);
        }
        if (l.startsWith(altPrefix)) {
          return '$prefix${l.substring(altPrefix.length)}';
        }
        if (l.startsWith(prefix)) return l;
        return '$prefix$l';
      }).toList();

      final replacementBlock = transformedLines.join('\n');
      final newText =
          text.replaceRange(lineStart, lineEnd, replacementBlock);
      final newCursor = lineStart + replacementBlock.length;

      _previousContentText = newText;
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
      _contentFocusNode.requestFocus();
      setState(() => _isDirty = true);
      return;
    }
  }

  void _showInsertLinkSheet() {
    final text = _contentController.text;
    final sel = _contentController.selection;
    final initialLabel =
        (sel.isValid && sel.start != sel.end) ? text.substring(sel.start, sel.end) : '';

    final labelCtrl = TextEditingController(text: initialLabel);
    final urlCtrl = TextEditingController(text: 'https://');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: 'Insert link',
        description: 'Add a clickable link into your memo.',
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: TextField(
                  controller: labelCtrl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'LINK TEXT',
                    labelStyle: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                    hintText: 'e.g. Figma Design System',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: TextField(
                  controller: urlCtrl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    labelStyle: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                    hintText: 'https://...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final label = labelCtrl.text.trim().isEmpty
                        ? 'Link'
                        : labelCtrl.text.trim();
                    final url = urlCtrl.text.trim().isEmpty
                        ? 'https://memospace.app'
                        : urlCtrl.text.trim();
                    final markdownLink = '[$label]($url)';

                    final start = sel.isValid ? sel.start : text.length;
                    final end = sel.isValid ? sel.end : text.length;
                    final newText =
                        text.replaceRange(start, end, markdownLink);
                    _previousContentText = newText;
                    _contentController.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(
                        offset: start + markdownLink.length,
                      ),
                    );
                    setState(() => _isDirty = true);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Insert link',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Menampilkan bottom sheet Add attachment (Photo, Video, PDF, Document)
  /// yang benar-benar membuka File Explorer atau Kamera perangkat
  void _showAddAttachmentSheet() {
    if (!_canEdit) return;

    final options = [
      {
        'label': 'Photo',
        'sub': 'Camera or gallery image',
        'icon': Icons.image_outlined,
        'bg': AppTheme.peach,
        'color': AppTheme.caramel,
      },
      {
        'label': 'Video',
        'sub': 'Record camera or video file',
        'icon': Icons.videocam_outlined,
        'bg': AppTheme.lilac,
        'color': AppTheme.plum,
      },
      {
        'label': 'PDF',
        'sub': 'Choose .pdf document',
        'icon': Icons.picture_as_pdf_outlined,
        'bg': AppTheme.mint,
        'color': AppTheme.olive,
      },
      {
        'label': 'Document',
        'sub': 'Word, Excel, TXT, ZIP',
        'icon': Icons.insert_drive_file_outlined,
        'bg': AppTheme.surface,
        'color': AppTheme.ink,
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: 'Add attachment',
        description:
            'Attach a photo, video, PDF, or document from your camera or device.',
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final opt = options[index];
            final type = opt['label'] as String;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pop(ctx);
                  if (type == 'Photo' || type == 'Video') {
                    _showMediaSourceChoiceSheet(type);
                  } else {
                    _pickFileFromDevice(type, useCamera: false);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [AppTheme.shadowSoft],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: opt['bg'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          opt['icon'] as IconData,
                          color: opt['color'] as Color,
                          size: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt['sub'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.faint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Pilihan sumber untuk Photo / Video: Buka Kamera langsung atau Pilih File dari Perangkat
  void _showMediaSourceChoiceSheet(String type) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: type == 'Photo' ? 'Add Photo' : 'Add Video',
        description:
            'Choose whether to capture from camera or browse files on your device.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceOptionTile(
              icon: Icons.camera_alt_outlined,
              iconBg: AppTheme.peach,
              iconColor: AppTheme.caramel,
              title: type == 'Photo'
                  ? 'Open Camera (Take Photo)'
                  : 'Open Camera (Record Video)',
              subtitle: 'Use your device camera directly',
              onTap: () {
                Navigator.pop(ctx);
                _pickFileFromDevice(type, useCamera: true);
              },
            ),
            const SizedBox(height: 10),
            _buildSourceOptionTile(
              icon: Icons.folder_open_rounded,
              iconBg: AppTheme.mint,
              iconColor: AppTheme.olive,
              title: 'Choose from Device / Gallery',
              subtitle: type == 'Photo'
                  ? 'Select JPG, PNG, WebP image file'
                  : 'Select MP4, MOV, WebM video file',
              onTap: () {
                Navigator.pop(ctx);
                _pickFileFromDevice(type, useCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOptionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.faint,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFileFromDevice(
    String type, {
    required bool useCamera,
  }) async {
    final picked = await pickAttachmentFromDevice(
      context: context,
      type: type,
      useCamera: useCamera,
    );

    if (!mounted || picked == null) return;

    setState(() {
      _attachments.add({
        'id': 'att-${DateTime.now().millisecondsSinceEpoch}',
        'type': picked.type,
        'name': picked.name,
        'meta': '${picked.sizeLabel} · Added just now',
        if (picked.dataUrl != null) 'dataUrl': picked.dataUrl,
      });
      _isDirty = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lampiran "${picked.name}" berhasil ditambahkan'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previewAttachment(Map<String, dynamic> att) {
    final dataUrl = att['dataUrl'] as String?;
    final name = (att['name'] as String?) ?? 'Attachment';
    final meta = (att['meta'] as String?) ?? '';
    final type = (att['type'] as String?) ?? 'Document';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: name,
        description: '$type · $meta',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dataUrl != null && dataUrl.startsWith('data:image'))
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: Image.memory(
                    base64Decode(dataUrl.split(',').last),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: Column(
                  children: [
                    Icon(
                      type == 'Video'
                          ? Icons.videocam_rounded
                          : type == 'PDF'
                              ? Icons.picture_as_pdf_rounded
                              : Icons.insert_drive_file_rounded,
                      size: 42,
                      color: AppTheme.ink,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Close preview',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan Action Sheet bagian kanan atas ("More actions" + "Delete memo")
  /// Hanya ditampilkan untuk memo yang sudah ada (!_isCreating)
  void _showMoreActionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: 'More actions',
        description: 'Manage this memo or share it with others.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMoreActionTile(
              ctx: ctx,
              icon: Icons.share_outlined,
              label: 'Share memo',
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memo link copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMoreActionTile(
              ctx: ctx,
              icon: Icons.folder_open_rounded,
              label: 'Move to workspace',
              onTap: () {
                Navigator.pop(ctx);
                if (_canEdit) _showWorkspaceSelectorSheet();
              },
            ),
            const SizedBox(height: 8),
            _buildMoreActionTile(
              ctx: ctx,
              icon: Icons.copy_rounded,
              label: 'Duplicate memo',
              onTap: () async {
                Navigator.pop(ctx);
                final workspaces = context.read<WorkspaceCubit>().state;
                final workspaceId = _activeWorkspaceId ??
                    (workspaces.isNotEmpty
                        ? workspaces.first.id
                        : 'personal-space');
                await context.read<MemoCubit>().addMemo(
                      workspaceId: workspaceId,
                      title: '${_titleController.text.trim().isEmpty ? 'Untitled memo' : _titleController.text.trim()} (Copy)',
                      content: _contentController.text,
                      tag: _currentTag,
                      dueDate: _currentDueDate,
                      checklistTitle: _checklistTitleController.text.trim(),
                      attachments:
                          List<Map<String, dynamic>>.from(_attachments),
                      checklist:
                          List<Map<String, dynamic>>.from(_checklistItems),
                    );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memo duplicated'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (_canEdit) ...[
              const SizedBox(height: 8),
              _buildMoreActionTile(
                ctx: ctx,
                icon: Icons.delete_outline_rounded,
                label: 'Delete memo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteMemo();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionTile({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: isDestructive ? AppTheme.blush : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDestructive ? AppTheme.coral : AppTheme.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDestructive ? AppTheme.coral : AppTheme.ink,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDestructive ? AppTheme.coral : AppTheme.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMemo() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.canvas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus memo ini?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Memo beserta komentarnya akan dihapus dari workspace.',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (_activeMemoId != null) {
                await context.read<MemoCubit>().delete(
                      _activeWorkspaceId ?? '',
                      _activeMemoId!,
                    );
              }
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memo berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coral,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    if (!_canEdit) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsed = DateTime.tryParse(_currentDueDate);
    final initial =
        (parsed != null && !parsed.isBefore(today)) ? parsed : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(2032),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _currentDueDate = formatted;
        _isDirty = true;
      });
    }
  }

  void _addChecklistItem() {
    if (!_canEdit) return;
    final text = _checklistController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklistItems.add({
        'id': 'check-${DateTime.now().millisecondsSinceEpoch}',
        'text': text,
        'done': false,
      });
      _checklistController.clear();
      _isDirty = true;
    });
  }

  void _startEditingChecklistItem(int index) {
    if (!_canEdit) return;
    setState(() {
      _editingChecklistIndex = index;
      _editChecklistTextController.text =
          (_checklistItems[index]['text'] as String?) ?? '';
    });
  }

  void _saveEditingChecklistItem(int index) {
    final trimmed = _editChecklistTextController.text.trim();
    setState(() {
      if (trimmed.isNotEmpty) {
        _checklistItems[index]['text'] = trimmed;
        _isDirty = true;
      }
      _editingChecklistIndex = null;
    });
  }

  Future<void> _submitComment({String? parentId}) async {
    final controller = parentId != null ? _replyController : _commentController;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();
    if (parentId != null) {
      setState(() {
        _replyingToCommentId = null;
        _replyingToAuthorName = null;
      });
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final authorName =
        (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty)
            ? currentUser.displayName!
            : 'Naya Anindita';
    final initials = authorName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    if (_activeWorkspaceId != null &&
        _activeMemoId != null &&
        currentUser != null &&
        !_activeMemoId!.startsWith('memo-')) {
      try {
        await _commentRepo.add(
          _activeWorkspaceId!,
          _activeMemoId!,
          _titleController.text.trim().isEmpty
              ? 'Untitled memo'
              : _titleController.text.trim(),
          text,
          parentId: parentId,
        );
        return;
      } catch (_) {}
    }

    setState(() {
      _localComments.add(
        Comment(
          id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
          memoId: _activeMemoId ?? 'draft',
          authorName: authorName,
          initials: initials.isEmpty ? 'NA' : initials,
          text: text,
          createdAt: DateTime.now(),
          parentId: parentId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaces = context.watch<WorkspaceCubit>().state;
    final activeWorkspace = _resolveActiveWorkspace(workspaces);
    final workspaceName = activeWorkspace?.name ?? 'Personal';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildDetailHeader(),
              const SizedBox(height: 16),
              _buildMainEditorCard(workspaceName),
              if (_canEdit || _attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAttachmentsCard(),
              ],
              if (_canEdit || _checklistItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildChecklistCard(),
              ],
              // Hanya tampilkan Comments jika memo sudah dibuat (!_isCreating)
              if (!_isCreating) ...[
                const SizedBox(height: 16),
                _buildCommentsCard(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Jika sedang membuat memo baru (_isCreating), tampilkan tombol pill panjang di paling bawah layar
      bottomNavigationBar: _isCreating
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.line.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _saveDocument(closeAfterCreate: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      _isSaving ? 'Creating memo...' : 'Create Memo',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  /// DetailHeader:
  /// - Saat membuat memo baru (_isCreating): tampilan editorial "CREATE MEMO / New memo" yang tegas & rapi tanpa MoreHorizontal
  /// - Saat melihat/edit memo (!_isCreating): "MEMO WORKSPACE / Memo details" + tombol MoreHorizontal di kanan atas
  Widget _buildDetailHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [AppTheme.shadowSoft],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.ink,
              size: 18,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isCreating ? 'CREATE MEMO' : 'MEMO DETAILS',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppTheme.faint,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isCreating ? 'New memo' : 'Workspace note',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                letterSpacing: -0.5,
                height: 1.15,
              ),
            ),
          ],
        ),
        if (_isCreating)
          const SizedBox(width: 40, height: 40)
        else
          GestureDetector(
            onTap: _showMoreActionsSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [AppTheme.shadowSoft],
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.ink,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainEditorCard(String workspaceName) {
    final toolbarItems = [
      {'icon': Icons.format_bold_rounded, 'label': 'Bold'},
      {'icon': Icons.format_italic_rounded, 'label': 'Italic'},
      {'icon': Icons.format_list_bulleted_rounded, 'label': 'Bullet list'},
      {'icon': Icons.format_quote_rounded, 'label': 'Quote'},
      {'icon': Icons.link_rounded, 'label': 'Link'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Tag Pill + Saved status + Save/Saved button (hanya saat edit memo yang sudah ada)
          Row(
            children: [
              GestureDetector(
                onTap: _canEdit ? _showWorkspaceSelectorSheet : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.peach,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grid_view_rounded,
                        size: 11,
                        color: AppTheme.caramel,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workspaceName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.caramel,
                        ),
                      ),
                      if (_canEdit) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 13,
                          color: AppTheme.caramel,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isCreating
                      ? 'New draft in $workspaceName'
                      : (_canEdit
                          ? (_isDirty ? 'Unsaved changes' : _savedAtText)
                          : 'By $_authorName · $_savedAtText'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.faint,
                  ),
                ),
              ),
              // Tombol kecil Save/Saved hanya muncul saat mengedit memo yang sudah dibuat (!_isCreating)
              if (!_isCreating && _canEdit)
                GestureDetector(
                  onTap: () => _saveDocument(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _isDirty ? AppTheme.ink : AppTheme.mint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: _isDirty ? Colors.white : AppTheme.olive,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDirty ? 'Save' : 'Saved',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _isDirty ? Colors.white : AppTheme.olive,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!_isCreating && !_canEdit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 11,
                        color: AppTheme.muted,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Read only',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Due Date Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_currentDueDate.isNotEmpty) ...[
                DeadlineBadge(
                  date: _currentDueDate,
                  onTap: _canEdit ? _pickDueDate : null,
                ),
                if (_canEdit) ...[
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentDueDate = '';
                      _isDirty = true;
                    }),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.faint,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else if (_canEdit)
                GestureDetector(
                  onTap: _pickDueDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: AppTheme.ink,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Set due date',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Memo Title Input
          TextField(
            controller: _titleController,
            readOnly: !_canEdit,
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
              letterSpacing: -0.5,
              height: 1.25,
            ),
            decoration: const InputDecoration(
              hintText: 'Untitled memo',
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.faint,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            ),
          ),

          // Formatting Toolbar + Attach Button
          if (_canEdit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.line),
                  bottom: BorderSide(color: AppTheme.line),
                ),
              ),
              child: Row(
                children: [
                  ...toolbarItems.map((tool) {
                    final label = tool['label'] as String;
                    final isActive = _isFormatActive(label);
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Material(
                        color: isActive ? AppTheme.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),
                          onTap: () => _applyFormatting(label),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              tool['icon'] as IconData,
                              size: 16,
                              color: isActive ? Colors.white : AppTheme.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showAddAttachmentSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 13,
                            color: AppTheme.ink,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Attach',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Memo Body Content Input dengan Rich Visual Formatting
          TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            readOnly: !_canEdit,
            maxLines: null,
            minLines: 5,
            onChanged: _handleContentChanged,
            onTap: () => setState(() {}),
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.muted,
              height: 1.75,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Write your thoughts, notes, or project brief here...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppTheme.faint,
                height: 1.75,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Attachments Section
  Widget _buildAttachmentsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATTACHMENTS (${_attachments.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                  letterSpacing: 0.8,
                ),
              ),
              if (_canEdit)
                GestureDetector(
                  onTap: _showAddAttachmentSheet,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: AppTheme.ink),
                      SizedBox(width: 2),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_attachments.isEmpty)
            GestureDetector(
              onTap: _canEdit ? _showAddAttachmentSheet : null,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.line,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _canEdit
                        ? '+ Attach photo, video, PDF, or document from device/camera'
                        : 'No attachments on this memo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(_attachments.length, (idx) {
                final att = _attachments[idx];
                final type = (att['type'] as String?) ?? 'Document';
                final dataUrl = att['dataUrl'] as String?;

                IconData icon = Icons.insert_drive_file_outlined;
                Color bg = AppTheme.surface;
                Color iconColor = AppTheme.ink;
                if (type == 'Photo') {
                  icon = Icons.image_outlined;
                  bg = AppTheme.peach;
                  iconColor = AppTheme.caramel;
                } else if (type == 'Video') {
                  icon = Icons.videocam_outlined;
                  bg = AppTheme.lilac;
                  iconColor = AppTheme.plum;
                } else if (type == 'PDF') {
                  icon = Icons.picture_as_pdf_outlined;
                  bg = AppTheme.mint;
                  iconColor = AppTheme.olive;
                }

                return Container(
                  margin: EdgeInsets.only(
                    bottom: idx == _attachments.length - 1 ? 0 : 8,
                  ),
                  child: Material(
                    color: AppTheme.canvas,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _previewAttachment(att),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            if (dataUrl != null &&
                                dataUrl.startsWith('data:image'))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(dataUrl.split(',').last),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        Icon(icon, size: 17, color: iconColor),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, size: 17, color: iconColor),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (att['name'] as String?) ?? 'Attachment',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${att['type']} · ${att['meta']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.faint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_canEdit)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachments.removeAt(idx);
                                    _isDirty = true;
                                  });
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 14,
                                    color: AppTheme.faint,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  /// Checklist Section dengan input Judul Checklist
  Widget _buildChecklistCard() {
    final doneCount = _checklistItems.where((c) => c['done'] == true).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CHECKLIST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$doneCount of ${_checklistItems.length} done',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.olive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Input Judul Checklist
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.canvas,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.checklist_rtl_rounded,
                  size: 16,
                  color: AppTheme.olive,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _checklistTitleController,
                    readOnly: !_canEdit,
                    onChanged: (_) {
                      if (!_isDirty) setState(() => _isDirty = true);
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Checklist title (e.g. Launch tasks, Sprint goals)...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.faint,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          if (_checklistItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'No checklist items yet.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.faint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Column(
              children: List.generate(_checklistItems.length, (idx) {
                final item = _checklistItems[idx];
                final isDone = item['done'] == true;
                final isEditing = _editingChecklistIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _canEdit
                            ? () {
                                setState(() {
                                  _checklistItems[idx]['done'] = !isDone;
                                  _isDirty = true;
                                });
                              }
                            : null,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isDone ? AppTheme.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: isDone
                                ? null
                                : Border.all(
                                    color: AppTheme.faint,
                                    width: 1.5,
                                  ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: isEditing
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.canvas,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        controller:
                                            _editChecklistTextController,
                                        autofocus: true,
                                        onSubmitted: (_) =>
                                            _saveEditingChecklistItem(idx),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.ink,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _saveEditingChecklistItem(idx),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.ink,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Done',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: _canEdit
                                    ? () {
                                        setState(() {
                                          _checklistItems[idx]['done'] =
                                              !isDone;
                                          _isDirty = true;
                                        });
                                      }
                                    : null,
                                child: Text(
                                  (item['text'] as String?) ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDone ? AppTheme.faint : AppTheme.ink,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                      ),
                      if (_canEdit && !isEditing) ...[
                        GestureDetector(
                          onTap: () => _startEditingChecklistItem(idx),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: AppTheme.faint,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _checklistItems.removeAt(idx);
                              _isDirty = true;
                            });
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 14,
                              color: AppTheme.faint,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          if (_canEdit) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.canvas,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _checklistController,
                      onSubmitted: (_) => _addChecklistItem(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Add a checklist item...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.faint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addChecklistItem,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 13, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Comments Section (hanya untuk memo yang sudah dibuat)
  Widget _buildCommentsCard() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final hasLiveFirestoreComments = _activeWorkspaceId != null &&
        _activeMemoId != null &&
        currentUser != null &&
        !_activeMemoId!.startsWith('memo-');

    if (hasLiveFirestoreComments) {
      return StreamBuilder<List<Comment>>(
        stream: _commentRepo.watch(_activeWorkspaceId!, _activeMemoId!),
        builder: (context, snapshot) {
          final comments = snapshot.data ?? _localComments;
          return _buildCommentsContent(comments);
        },
      );
    }

    return _buildCommentsContent(_localComments);
  }

  Widget _buildCommentsContent(List<Comment> comments) {
    final topLevel = comments.where((c) => c.parentId == null).toList();
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentName =
        (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty)
            ? currentUser.displayName!
            : 'Naya Anindita';
    final userInitials = currentName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMMENTS (${comments.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                  letterSpacing: 0.8,
                ),
              ),
              const Text(
                'Thread',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.faint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 22,
                    color: AppTheme.faint,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada komentar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Jadilah yang pertama menulis komentar di bawah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.faint,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: topLevel.map((comment) {
                final replies = comments
                    .where((c) => c.parentId == comment.id)
                    .toList();
                final isReplyingHere = _replyingToCommentId == comment.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSingleCommentRow(comment, isReply: false),
                      if (replies.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 28, top: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.line,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Column(
                              children: replies
                                  .map(
                                    (r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildSingleCommentRow(
                                        r,
                                        isReply: true,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      if (isReplyingHere)
                        Padding(
                          padding: const EdgeInsets.only(left: 28, top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.canvas,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextField(
                                    controller: _replyController,
                                    autofocus: true,
                                    onSubmitted: (_) =>
                                        _submitComment(parentId: comment.id),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.ink,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Reply to ${_replyingToAuthorName ?? comment.authorName}...',
                                      hintStyle: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.faint,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    _submitComment(parentId: comment.id),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.ink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppTheme.ink,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userInitials.isEmpty ? 'NA' : userInitials,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.canvas,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onSubmitted: (_) => _submitComment(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.faint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _submitComment(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppTheme.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCommentRow(Comment comment, {required bool isReply}) {
    final avatarBg = isReply ? AppTheme.lilac : AppTheme.peach;
    final avatarTextColor = isReply ? AppTheme.plum : AppTheme.caramel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isReply ? 26 : 30,
          height: isReply ? 26 : 30,
          decoration: BoxDecoration(
            color: avatarBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            comment.initials.isEmpty ? 'M' : comment.initials,
            style: TextStyle(
              fontSize: isReply ? 8 : 9,
              fontWeight: FontWeight.w700,
              color: avatarTextColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      fontSize: isReply ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  Text(
                    DateFormatter.getRelativeTimeText(comment.createdAt),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.faint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.text,
                style: TextStyle(
                  fontSize: isReply ? 11 : 12,
                  color: AppTheme.muted,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isReply) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_replyingToCommentId == comment.id) {
                        _replyingToCommentId = null;
                        _replyingToAuthorName = null;
                      } else {
                        _replyingToCommentId = comment.id;
                        _replyingToAuthorName = comment.authorName;
                      }
                    });
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 12,
                        color: AppTheme.muted,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
