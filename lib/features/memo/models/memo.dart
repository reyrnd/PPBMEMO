import 'package:cloud_firestore/cloud_firestore.dart';

class Memo {
  final String id;
  final String title;
  final String preview;
  final String content;
  final String meta;
  final String tag;
  final String dueDate;
  final String authorId;
  final String workspaceId;
  final String authorName;
  final String? fileName;
  final String? taskCount;
  final bool isPinned;
  final bool isBookmarked;
  final DateTime updatedAt;
  final double? boardX;
  final double? boardY;
  final double? progress;
  final String checklistTitle;
  final String status; // 'todo', 'doing', 'done'
  final String assignee;
  final String assigneeTone;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> checklist;

  const Memo({
    required this.id,
    required this.title,
    required this.preview,
    required this.content,
    required this.meta,
    required this.tag,
    required this.dueDate,
    this.authorId = '',
    this.workspaceId = '',
    this.authorName = '',
    this.fileName,
    this.taskCount,
    this.isPinned = false,
    this.isBookmarked = false,
    required this.updatedAt,
    this.boardX,
    this.boardY,
    this.progress,
    this.checklistTitle = '',
    this.status = 'todo',
    this.assignee = '',
    this.assigneeTone = 'dark',
    this.attachments = const [],
    this.checklist = const [],
  });

  String get category => tag;
  DateTime get createdAt => updatedAt;

  factory Memo.fromMap(
    Map<String, dynamic> map,
    String documentId, {
    String workspaceId = '',
  }) {
    final updatedAt = (map['updatedAt'] as Timestamp?)?.toDate() ??
        (map['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.now();

    final rawAttachments = map['attachments'];
    final attachments = rawAttachments is List
        ? rawAttachments
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : const <Map<String, dynamic>>[];

    final rawChecklist = map['checklist'];
    final checklist = rawChecklist is List
        ? rawChecklist
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : const <Map<String, dynamic>>[];

    double? computedProgress =
        map['progress'] != null ? (map['progress'] as num).toDouble() : null;
    if (computedProgress == null && checklist.isNotEmpty) {
      final doneCount = checklist.where((c) => c['done'] == true).length;
      computedProgress = doneCount / checklist.length;
    }

    String rawStatus = (map['status'] as String?) ?? '';
    if (rawStatus.isEmpty) {
      if (computedProgress != null && computedProgress >= 1.0) {
        rawStatus = 'done';
      } else if (computedProgress != null && computedProgress > 0.0) {
        rawStatus = 'doing';
      } else {
        rawStatus = 'todo';
      }
    }

    final authorName = map['authorName'] as String? ?? '';
    String rawAssignee = (map['assignee'] as String?) ?? '';
    if (rawAssignee.isEmpty && authorName.isNotEmpty) {
      final parts =
          authorName.trim().split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        rawAssignee = (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
            .toUpperCase();
      }
    }
    if (rawAssignee.isEmpty) {
      rawAssignee = 'NA';
    }

    return Memo(
      id: documentId,
      title: map['title'] ?? '',
      preview: map['preview'] ?? '',
      content: map['content'] ?? '',
      meta: map['meta'] ?? '',
      tag: map['tag'] ?? 'Personal',
      dueDate: map['dueDate'] ?? '',
      authorId: map['authorId'] ?? '',
      workspaceId: workspaceId.isNotEmpty
          ? workspaceId
          : (map['workspaceId'] as String? ?? ''),
      authorName: authorName,
      fileName: map['fileName'] as String?,
      taskCount: map['taskCount']?.toString(),
      isPinned: map['isPinned'] as bool? ?? false,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      updatedAt: updatedAt,
      boardX: (map['boardX'] as num?)?.toDouble(),
      boardY: (map['boardY'] as num?)?.toDouble(),
      progress: computedProgress,
      checklistTitle: map['checklistTitle'] as String? ?? '',
      status: rawStatus,
      assignee: rawAssignee,
      assigneeTone: map['assigneeTone'] as String? ?? 'dark',
      attachments: attachments,
      checklist: checklist,
    );
  }

  factory Memo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final wsId = data['workspaceId'] as String? ?? '';
    return Memo.fromMap(data, doc.id, workspaceId: wsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'preview': preview,
      'content': content,
      'meta': meta,
      'tag': tag,
      'dueDate': dueDate,
      'authorId': authorId,
      'workspaceId': workspaceId,
      'authorName': authorName,
      'fileName': fileName,
      'taskCount': taskCount,
      'isPinned': isPinned,
      'isBookmarked': isBookmarked,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'boardX': boardX,
      'boardY': boardY,
      'progress': progress,
      'checklistTitle': checklistTitle,
      'status': status,
      'assignee': assignee,
      'assigneeTone': assigneeTone,
      'attachments': attachments,
      'checklist': checklist,
    };
  }

  Memo copyWith({
    String? title,
    String? preview,
    String? content,
    String? meta,
    String? tag,
    String? dueDate,
    String? authorId,
    String? workspaceId,
    String? authorName,
    String? fileName,
    String? taskCount,
    bool? isPinned,
    bool? isBookmarked,
    DateTime? updatedAt,
    double? boardX,
    double? boardY,
    double? progress,
    String? checklistTitle,
    String? status,
    String? assignee,
    String? assigneeTone,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? checklist,
  }) {
    return Memo(
      id: id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      content: content ?? this.content,
      meta: meta ?? this.meta,
      tag: tag ?? this.tag,
      dueDate: dueDate ?? this.dueDate,
      authorId: authorId ?? this.authorId,
      workspaceId: workspaceId ?? this.workspaceId,
      authorName: authorName ?? this.authorName,
      fileName: fileName ?? this.fileName,
      taskCount: taskCount ?? this.taskCount,
      isPinned: isPinned ?? this.isPinned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      updatedAt: updatedAt ?? this.updatedAt,
      boardX: boardX ?? this.boardX,
      boardY: boardY ?? this.boardY,
      progress: progress ?? this.progress,
      checklistTitle: checklistTitle ?? this.checklistTitle,
      status: status ?? this.status,
      assignee: assignee ?? this.assignee,
      assigneeTone: assigneeTone ?? this.assigneeTone,
      attachments: attachments ?? this.attachments,
      checklist: checklist ?? this.checklist,
    );
  }
}
