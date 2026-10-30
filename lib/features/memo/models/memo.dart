import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Memo {
  final String id;
  final String workspaceId;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime updatedAt;

  // Metadata tampilan sementara. Belum disimpan dalam dokumen memo.
  final String category;
  final String? fileName;
  final String? taskCount;
  final bool isPinned;
  final bool isBookmarked;
  final bool isArchived;
  final double? boardX;
  final double? boardY;
  final String? boardStatus; // 'planned' | 'inProgress' | 'completed'

  const Memo({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.content,
    this.authorId = '',
    required this.authorName,
    required this.updatedAt,
    this.category = 'Umum',
    this.fileName,
    this.taskCount,
    this.isPinned = false,
    this.isBookmarked = false,
    this.isArchived = false,
    this.boardX,
    this.boardY,
    this.boardStatus = 'planned',
  });

  Memo copyWith({
    String? id,
    String? workspaceId,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? updatedAt,
    String? category,
    String? fileName,
    String? taskCount,
    bool? isPinned,
    bool? isBookmarked,
    bool? isArchived,
  }) {
    return Memo(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      fileName: fileName ?? this.fileName,
      taskCount: taskCount ?? this.taskCount,
      isPinned: isPinned ?? this.isPinned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  factory Memo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final workspace = doc.reference.parent.parent;

    if (workspace == null) {
      throw StateError('Dokumen memo harus berada di dalam workspace');
    }

    return Memo(
      id: doc.id,
      workspaceId: workspace.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBookmarked: (data['bookmarkedBy'] as List? ?? [])
          .contains(FirebaseAuth.instance.currentUser?.uid),
      isArchived: data['archived'] ?? false,
      boardX: (data['boardX'] as num?)?.toDouble(),
      boardY: (data['boardY'] as num?)?.toDouble(),
      boardStatus: data['boardStatus'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
      };
}
