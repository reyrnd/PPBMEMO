import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String memoId;
  final String authorName;
  final String initials;
  final String text;
  final DateTime createdAt;
  final String? parentId;

  const Comment({
    required this.id,
    required this.memoId,
    required this.authorName,
    required this.initials,
    required this.text,
    required this.createdAt,
    this.parentId,
  });

  bool get isReply => parentId != null;

  Comment copyWith({
    String? id,
    String? memoId,
    String? authorName,
    String? initials,
    String? text,
    DateTime? createdAt,
    String? parentId,
  }) {
    return Comment(
      id: id ?? this.id,
      memoId: memoId ?? this.memoId,
      authorName: authorName ?? this.authorName,
      initials: initials ?? this.initials,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }

  factory Comment.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc, String memoId) {
    final d = doc.data()!;
    final name = d['authorName'] as String? ?? '';
    return Comment(
      id: doc.id,
      memoId: memoId,
      authorName: name,
      initials: name.isEmpty
          ? '?'
          : name
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase(),
      text: d['text'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentId: d['parentId'],
    );
  }
}
