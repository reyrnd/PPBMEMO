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
}
