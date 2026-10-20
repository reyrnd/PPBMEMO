class Memo {
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
}
