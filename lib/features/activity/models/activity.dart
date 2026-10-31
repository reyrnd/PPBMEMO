import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { memo, file, comment }

class Activity {
  final String id;
  final String initials;
  final String action;
  final String target;
  final String workspaceId;
  final String workspaceName;
  final String memoId;
  final DateTime time;
  final ActivityType type;

  const Activity({
    this.id = '',
    required this.initials,
    required this.action,
    required this.target,
    this.workspaceId = '',
    this.workspaceName = '',
    this.memoId = '',
    required this.time,
    this.type = ActivityType.memo,
  });

  factory Activity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceName, {
    String fallbackWorkspaceId = '',
  }) {
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
      'workspace_created' => 'membuat ruang kerja',
      'member_joined' => 'bergabung ke ruang kerja',
      'memo_created' => 'membuat memo',
      'memo_edited' => 'mengedit catatan',
      'file_uploaded' => 'mengunggah berkas pada',
      'comment_added' => 'mengomentari',
      _ => 'memperbarui',
    };

    return Activity(
      id: doc.id,
      initials: initials,
      action: '${actorName.isEmpty ? 'Anggota' : actorName} $actionText',
      target: d['targetTitle'] as String? ?? workspaceName,
      workspaceId: (d['workspaceId'] as String?)?.isNotEmpty == true
          ? d['workspaceId'] as String
          : fallbackWorkspaceId,
      workspaceName: workspaceName,
      memoId: d['memoId'] as String? ?? '',
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
