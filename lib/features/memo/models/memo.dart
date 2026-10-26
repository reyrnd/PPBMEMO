class Memo {
  final String id;
  final String category;
  final String title;
  final String content;
  final String? fileName;
  final String? taskCount;
  final String author;
  final String time;
  final bool isPinned;
  final bool isBookmarked;

  const Memo({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    this.fileName,
    this.taskCount,
    required this.author,
    required this.time,
    required this.isPinned,
    this.isBookmarked = false,
  });

  Memo copyWith({
    String? id,
    String? category,
    String? title,
    String? content,
    String? fileName,
    String? taskCount,
    String? author,
    String? time,
    bool? isPinned,
    bool? isBookmarked,
  }) {
    return Memo(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      fileName: fileName ?? this.fileName,
      taskCount: taskCount ?? this.taskCount,
      author: author ?? this.author,
      time: time ?? this.time,
      isPinned: isPinned ?? this.isPinned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
