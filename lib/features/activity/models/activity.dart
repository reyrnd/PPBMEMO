enum ActivityType { memo, file, comment }

class Activity {
  final String initials;
  final String action;
  final String target;
  final DateTime time;
  final ActivityType type;

  const Activity({
    required this.initials,
    required this.action,
    required this.target,
    required this.time,
    this.type = ActivityType.memo,
  });
}
