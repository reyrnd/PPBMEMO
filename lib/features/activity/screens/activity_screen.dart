// activity_screen.dart
import 'package:flutter/material.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/activity/widgets/empty_activity_state.dart';
import 'package:memospace/features/activity/data/activity_repository.dart';
import '../../../core/app_theme.dart';
import '../models/activity.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final Stream<List<Activity>> _activities;
  int _selectedFilterIndex = 0; // 0: Semua, 1: Memo, 2: Berkas, 3: Komentar

  @override
  void initState() {
    super.initState();
    _activities = ActivityRepository().watchAllMyActivities();
  }

  List<Activity> _getGroupedActivities(
      String groupName, List<Activity> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final filteredList = activities.where((activity) {
      return switch (_selectedFilterIndex) {
        1 => activity.type == ActivityType.memo,
        2 => activity.type == ActivityType.file,
        3 => activity.type == ActivityType.comment,
        _ => true,
      };
    });

    return filteredList.where((activity) {
      final activityDate =
          DateTime(activity.time.year, activity.time.month, activity.time.day);

      if (groupName == 'HARI INI') {
        return activityDate.isAtSameMomentAs(today);
      } else if (groupName == 'KEMARIN') {
        return activityDate.isAtSameMomentAs(yesterday);
      } else {
        return activityDate.isBefore(yesterday);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MemoAppBar(),
      body: StreamBuilder<List<Activity>>(
        stream: _activities,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Aktivitas gagal dimuat.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allActivities = snapshot.data ?? const <Activity>[];
          final today = _getGroupedActivities('HARI INI', allActivities);
          final yesterday = _getGroupedActivities('KEMARIN', allActivities);
          final older = _getGroupedActivities('TERDAHULU', allActivities);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              const Text(
                'Aktivitas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pantau pembaruan dan progres kolaborasi tim',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('Semua', 0),
                    const SizedBox(width: 8),
                    _buildFilterPill('Memo', 1),
                    const SizedBox(width: 8),
                    _buildFilterPill('Berkas', 2),
                    const SizedBox(width: 8),
                    _buildFilterPill('Komentar', 3),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (today.isNotEmpty) _buildActivityGroup('HARI INI', today),
              if (yesterday.isNotEmpty)
                _buildActivityGroup('KEMARIN', yesterday),
              if (older.isNotEmpty)
                _buildActivityGroup('BEBERAPA HARI LALU', older),
              if (today.isEmpty && yesterday.isEmpty && older.isEmpty)
                const EmptyActivityState(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityGroup(String title, List<Activity> activities) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppTheme.border),
              itemBuilder: (context, index) =>
                  _buildActivityItem(activities[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, int index) {
    final bool isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF4F5F7),
            child: Text(
              activity.initials,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textPrimary, height: 1.3),
                    children: [
                      TextSpan(text: '${activity.action} '),
                      TextSpan(
                          text: activity.target,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_open_outlined,
                          size: 10, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        activity.workspaceName,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormatter.getRelativeTimeText(activity.time),
            style: const TextStyle(fontSize: 11, color: Colors.black38),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
