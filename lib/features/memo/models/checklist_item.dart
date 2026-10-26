class ChecklistItem {
  final String id;
  final String text;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.text,
    required this.isDone,
  });

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}

extension ChecklistItemListProgress on List<ChecklistItem> {
  String get progressText {
    final completedCount = where((item) => item.isDone).length;
    return '$completedCount/$length selesai';
  }
}
