import 'dart:async';

import 'package:memospace/features/activity/data/dummy_activities.dart';
import 'package:memospace/features/activity/models/activity.dart';

class ActivityRepository {
  ActivityRepository({List<Activity>? initialActivities})
      : _activities = List<Activity>.of(initialActivities ?? dummyActivities);

  final List<Activity> _activities;
  final StreamController<List<Activity>> _activityChanges =
      StreamController<List<Activity>>.broadcast();

  List<Activity> getActivities({ActivityType? type}) {
    final filtered = type == null
        ? _activities
        : _activities.where((activity) => activity.type == type);
    return List<Activity>.unmodifiable(filtered);
  }

  Stream<List<Activity>> watchActivities({ActivityType? type}) {
    return Stream<List<Activity>>.multi((controller) {
      controller.add(getActivities(type: type));
      final subscription = _activityChanges.stream.listen(
        (_) => controller.add(getActivities(type: type)),
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  void addActivity(Activity activity) {
    _activities.insert(0, activity);
    _activityChanges.add(getActivities());
  }

  Future<void> dispose() => _activityChanges.close();
}
