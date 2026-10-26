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

  Workspace copyWith({
    String? id,
    String? category,
    String? title,
    int? memoCount,
    int? fileCount,
    bool? hasPin,
    String? time,
    List<String>? memberInitials,
  }) {
    return Workspace(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      memoCount: memoCount ?? this.memoCount,
      fileCount: fileCount ?? this.fileCount,
      hasPin: hasPin ?? this.hasPin,
      time: time ?? this.time,
      memberInitials: memberInitials ?? this.memberInitials,
    );
  }
}
