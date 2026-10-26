class AppNotification {
  final String initials;
  final String? actorName;
  final String action;
  final String target;
  final String workspaceName;
  final DateTime time;
  final bool isUnread;
  final String type; // 'normal' atau 'invitation'

  AppNotification({
    required this.initials,
    this.actorName,
    required this.action,
    required this.target,
    required this.workspaceName,
    required this.time,
    required this.isUnread,
    this.type = 'normal',
  });
}
