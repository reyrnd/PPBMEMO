import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { memo, file, comment }

class Activity {
  final String initials;
  final String action;
  final String target;
  final String workspaceName;
  final DateTime time;
  final ActivityType type;

  const Activity({
    required this.initials,
    required this.action,
    required this.target,
    this.workspaceName = '',
    required this.time,
    this.type = ActivityType.memo,
  });

  factory Activity.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc, String workspaceName) {
    final d = doc.data()!;
    final actorName = d['actorName'] as String? ?? '';
    final eventType = d['type'] as String? ?? '';
    final nameParts = actorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = nameParts.isEmpty
        ? '?'
        : (nameParts.first[0] + (nameParts.length > 1 ? nameParts.last[0] : ''))
            .toUpperCase();
    final actionText = switch (eventType) {
      'memo_created' => 'membuat memo',
      'memo_edited' => 'mengedit catatan',
      'file_uploaded' => 'mengunggah berkas pada',
      'comment_added' => 'mengomentari',
      _ => 'memperbarui',
    };

    return Activity(
      initials: initials,
      action: '${actorName.isEmpty ? 'Anggota' : actorName} $actionText',
      target: d['targetTitle'] as String? ?? workspaceName,
      workspaceName: workspaceName,
      time: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: switch (eventType) {
        'file_uploaded' => ActivityType.file,
        'comment_added' => ActivityType.comment,
        _ => ActivityType.memo,
      },
    );
  }

  DateTime get createdAt => time;
}
