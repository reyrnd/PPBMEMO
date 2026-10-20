class Workspace {
  final String id;
  final String category;
  final String title;
  final int memoCount;
  final int fileCount;
  final bool hasPin;
  final String time;
  final List<String> memberInitials;

  const Workspace({
    required this.id,
    required this.category,
    required this.title,
    required this.memoCount,
    required this.fileCount,
    this.hasPin = false,
    required this.time,
    this.memberInitials = const [],
  });
}
