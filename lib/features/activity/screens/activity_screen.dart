// activity_screen.dart
import 'package:flutter/material.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/activity/widgets/empty_activity_state.dart';
import '../../../core/app_theme.dart';
import '../../activity/models/activity.dart';
import '../data/dummy_activities.dart'; // 💡 Sesuaikan path impor dummy data Anda

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _bottomNavIndex = 3;
  int _selectedFilterIndex = 0; // 0: Semua, 1: Memo, 2: Berkas, 3: Komentar

  // 💡 LOGIC 1: Mengubah DateTime menjadi string teks relatif
  String _getRelativeTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mnt lalu';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return '${difference.inHours} jam lalu';
    } else if (dateTime.day == now.subtract(const Duration(days: 1)).day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return 'Kemarin, ${dateTime.hour}:$minuteStr';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }

  // LOGIC 2: Memilah data dummy secara otomatis berdasarkan kelompok hari
  List<Activity> _getGroupedActivities(String groupName) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Kode penyaringan filter pill tetap dipertahankan
    List<Activity> filteredList = dummyActivities;
    if (_selectedFilterIndex == 1) {
      filteredList = dummyActivities
          .where(
              (a) => a.action.contains('catatan') || a.action.contains('memo'))
          .toList();
    } else if (_selectedFilterIndex == 2) {
      filteredList = dummyActivities
          .where((a) =>
              a.action.contains('berkas') ||
              a.action.contains('file') ||
              a.action.contains('lampiran'))
          .toList();
    } else if (_selectedFilterIndex == 3) {
      filteredList =
          dummyActivities.where((a) => a.action.contains('komentar')).toList();
    }

    return filteredList.where((activity) {
      final activityDate =
          DateTime(activity.time.year, activity.time.month, activity.time.day);

      if (groupName == 'HARI INI') {
        return activityDate.isAtSameMomentAs(today);
      } else if (groupName == 'KEMARIN') {
        return activityDate.isAtSameMomentAs(yesterday);
      } else {
        // 💡 UNTUK RIWAYAT YANG LEBIH TUA (2 hari lalu, 3 hari lalu, dst)
        return activityDate.isBefore(yesterday);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listHariIni = _getGroupedActivities('HARI INI');
    final listKemarin = _getGroupedActivities('KEMARIN');
    final listTerdahulu = _getGroupedActivities('TERDAHULU');

    final bool isAllEmpty =
        listHariIni.isEmpty && listKemarin.isEmpty && listTerdahulu.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MemoAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TITLE ---
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktivitas',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pantau pembaruan dan progres kolaborasi tim',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- HORIZONTAL FILTER PILLS ---
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

              // --- KELOMPOK 1: HARI INI ---
              if (listHariIni.isNotEmpty) ...[
                const Text(
                  'HARI INI',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFFE5E5E5), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listHariIni.length,
                    separatorBuilder: (context, index) => const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    itemBuilder: (context, index) {
                      final item = listHariIni[index];
                      return _buildActivityItem(
                        avatarText: item.initials,
                        actionTextFull: item.action,
                        boldTarget: item.target,
                        workspaceName: 'Proyek PPB',
                        timeText: _getRelativeTimeText(item.time),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- KELOMPOK 2: KEMARIN & SEBELUMNYA ---
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFFE5E5E5), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listKemarin.length,
                    separatorBuilder: (context, index) => const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    itemBuilder: (context, index) {
                      final item = listKemarin[index];
                      return _buildActivityItem(
                        avatarText: item.initials,
                        actionTextFull: item.action,
                        boldTarget: item.target,
                        workspaceName: 'Robotika AUV',
                        timeText: _getRelativeTimeText(item.time),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFFE5E5E5), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listTerdahulu.length,
                    separatorBuilder: (context, index) => const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    itemBuilder: (context, index) {
                      final item = listTerdahulu[index];
                      return _buildActivityItem(
                        avatarText: item.initials,
                        actionTextFull: item.action,
                        boldTarget: item.target,
                        workspaceName: 'Arsip Tim',
                        timeText: DateFormatter.getRelativeTimeText(
                            item.time), // Otomatis cetak "2 hari lalu", dll
                      );
                    },
                  ),
                ),
              ],

              if (isAllEmpty) const EmptyActivityState(),
              const SizedBox(height: 40),
            ],
          ),
        ),
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

  Widget _buildActivityItem({
    required String avatarText,
    required String actionTextFull,
    required String boldTarget,
    required String workspaceName,
    required String timeText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF4F5F7),
            child: Text(
              avatarText,
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
                      TextSpan(text: '$actionTextFull '),
                      TextSpan(
                          text: boldTarget,
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
                        workspaceName,
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
            timeText,
            style: const TextStyle(fontSize: 11, color: Colors.black38),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
