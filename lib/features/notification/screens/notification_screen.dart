import 'package:flutter/material.dart';
import 'package:memospace/features/activity/data/activity_repository.dart';
import 'package:memospace/features/activity/models/activity.dart';
import 'package:memospace/features/notification/models/app_notification.dart';
import 'package:memospace/features/notification/widgets/notification_tile.dart';
import '../../../core/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  final ValueChanged<AppNotification>? onAcceptInvitation;
  final ValueChanged<AppNotification>? onRejectInvitation;

  const NotificationScreen({
    super.key,
    this.onAcceptInvitation,
    this.onRejectInvitation,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilterIndex =
      0; // 0: Semua, 1: Belum dibaca, 2: Undangan, 3: Komentar
  late final Stream<List<Activity>> _activities;
  final Set<String> _readNotificationKeys = {};

  @override
  void initState() {
    super.initState();
    _activities = ActivityRepository().watchAllMyActivities();
  }

  String _activityKey(Activity activity) =>
      '${activity.time.microsecondsSinceEpoch}|${activity.action}|${activity.target}|${activity.workspaceName}';

  String _notificationKey(AppNotification notification) =>
      '${notification.time.microsecondsSinceEpoch}|${notification.action}|${notification.target}|${notification.workspaceName}';

  List<AppNotification> _toNotifications(List<Activity> activities) =>
      activities
          .map((activity) => AppNotification(
                initials: activity.initials,
                action: activity.action,
                target: activity.target,
                workspaceName: activity.workspaceName,
                time: activity.time,
                isUnread:
                    !_readNotificationKeys.contains(_activityKey(activity)),
                type: activity.type == ActivityType.comment
                    ? 'comment'
                    : 'normal',
              ))
          .toList();

  void _markNotificationRead(AppNotification notification) {
    setState(() => _readNotificationKeys.add(_notificationKey(notification)));
  }

  void _markAllRead(List<AppNotification> notifications) {
    setState(() {
      _readNotificationKeys.addAll(notifications.map(_notificationKey));
    });
  }

  List<AppNotification> _getGroupedNotifications(
    String groupName,
    List<AppNotification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // 1. Logika Filter Pill (Semua, Belum dibaca, Undangan, Komentar)
    final filteredList = switch (_selectedFilterIndex) {
      1 => notifications.where((n) => n.isUnread).toList(),
      2 => notifications.where((n) => n.type == 'invitation').toList(),
      3 => notifications.where((n) => n.type == 'comment').toList(),
      4 => notifications.where((n) => n.action.contains('menyebut')).toList(),
      _ => notifications,
    };

    // 2. Pembagian berdasarkan Kelompok Waktu
    return filteredList.where((notification) {
      final notificationDate = DateTime(notification.time.year,
          notification.time.month, notification.time.day);

      if (groupName == 'HARI INI') {
        return notificationDate.isAtSameMomentAs(today);
      } else if (groupName == 'KEMARIN') {
        return notificationDate.isAtSameMomentAs(yesterday);
      } else {
        return notificationDate.isBefore(yesterday);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Activity>>(
      stream: _activities,
      builder: (context, snapshot) {
        final notifications = _toNotifications(snapshot.data ?? const []);
        final listHariIni = _getGroupedNotifications('HARI INI', notifications);
        final listKemarin = _getGroupedNotifications('KEMARIN', notifications);
        final listTerdahulu =
            _getGroupedNotifications('TERDAHULU', notifications);

        // Menghitung jumlah notifikasi belum dibaca khusus hari ini
        final unreadCountHariIni = listHariIni.where((n) => n.isUnread).length;

        // Cek apakah semua kelompok data kosong setelah difilter
        final bool isAllEmpty =
            listHariIni.isEmpty && listKemarin.isEmpty && listTerdahulu.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Notifikasi',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: notifications.isEmpty
                    ? null
                    : () => _markAllRead(notifications),
                child: const Text(
                  'Tandai semua dibaca',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16, left: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1E1E1E),
                  child:
                      Icon(Icons.person_outline, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: snapshot.hasError
                ? const Center(
                    child: Text(
                      'Notifikasi gagal dimuat.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- HORIZONTAL FILTER PILLS ---
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterPill('Semua', 0),
                                  const SizedBox(width: 8),
                                  _buildFilterPill('Belum dibaca', 1),
                                  const SizedBox(width: 8),
                                  _buildFilterPill('Undangan', 2),
                                  const SizedBox(width: 8),
                                  _buildFilterPill('Komentar', 3),
                                  const SizedBox(width: 8),
                                  _buildFilterPill('Mention', 4),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // JIKA DATA KOSONG
                            if (isAllEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 80, horizontal: 24),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_off_outlined,
                                        size: 54, color: Colors.black38),
                                    SizedBox(height: 14),
                                    Text(
                                      'Tidak ada notifikasi',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pemberitahuan baru akan muncul jika ada aktivitas tim.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),

                            // --- KELOMPOK 1: HARI INI ---
                            if (listHariIni.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'HARI INI',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textSecondary,
                                        letterSpacing: 0.5),
                                  ),
                                  if (unreadCountHariIni > 0)
                                    Text(
                                      '$unreadCountHariIni belum dibaca',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: listHariIni
                                    .map((n) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: NotificationTile(
                                            notification: n,
                                            onTap: () =>
                                                _markNotificationRead(n),
                                            onAccept:
                                                widget.onAcceptInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onAcceptInvitation!(n),
                                            onReject:
                                                widget.onRejectInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onRejectInvitation!(n),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- KELOMPOK 2: KEMARIN ---
                            if (listKemarin.isNotEmpty) ...[
                              const Text(
                                'KEMARIN',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: listKemarin
                                    .map((n) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: NotificationTile(
                                            notification: n,
                                            onTap: () =>
                                                _markNotificationRead(n),
                                            onAccept:
                                                widget.onAcceptInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onAcceptInvitation!(n),
                                            onReject:
                                                widget.onRejectInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onRejectInvitation!(n),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- KELOMPOK 3: TERDAHULU ---
                            if (listTerdahulu.isNotEmpty) ...[
                              const Text(
                                'BEBERAPA HARI LALU',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: listTerdahulu
                                    .map((n) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: NotificationTile(
                                            notification: n,
                                            onTap: () =>
                                                _markNotificationRead(n),
                                            onAccept:
                                                widget.onAcceptInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onAcceptInvitation!(n),
                                            onReject:
                                                widget.onRejectInvitation ==
                                                        null
                                                    ? null
                                                    : () => widget
                                                        .onRejectInvitation!(n),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        );
      },
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
}
