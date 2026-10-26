enum AttachmentType { photo, video, document }

class Attachment {
  final String id;
  final String name;
  final AttachmentType type;
  final int sizeBytes;
  final String url;
  final int? durationSeconds;
  final int? pageCount;

  const Attachment({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeBytes,
    required this.url,
    this.durationSeconds,
    this.pageCount,
  });

  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = sizeBytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final value = size.toStringAsFixed(1);
    final formattedValue =
        value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
    return '$formattedValue ${units[unitIndex]}';
  }

  Attachment copyWith({
    String? id,
    String? name,
    AttachmentType? type,
    int? sizeBytes,
    String? url,
    int? durationSeconds,
    int? pageCount,
  }) {
    return Attachment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      url: url ?? this.url,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}
