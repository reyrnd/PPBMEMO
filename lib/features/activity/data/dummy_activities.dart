// dummy_data.dart
import '../../activity/models/activity.dart';

final List<Activity> dummyActivities = [
  Activity(
    initials: 'NP',
    action: 'Nabila P. menandai selesai pada',
    target: 'Rancangan UI Login',
    time: DateTime.now().subtract(const Duration(minutes: 10)), // Hari ini
    type: ActivityType.memo,
  ),
  Activity(
    initials: 'RR',
    action: 'Reynard R. menandai selesai pada',
    target: 'Rancangan UI dashboard',
    time: DateTime.now().subtract(const Duration(minutes: 20)), // Hari ini
    type: ActivityType.memo,
  ),
  Activity(
    initials: 'FK',
    action: 'Farhan K. menambahkan catatan di',
    target: 'Catatan Rapat Tim: Pembagian Modul Sensor',
    time: DateTime.now().subtract(const Duration(minutes: 25)), // Hari ini
    type: ActivityType.memo,
  ),
  Activity(
    initials: 'DA',
    action: 'Dimas A. mengunggah berkas baru di',
    target: 'Daftar User Story Sprint 2',
    time: DateTime.now().subtract(const Duration(hours: 3)), // Hari ini
    type: ActivityType.file,
  ),
  Activity(
    initials: 'DL',
    action: 'Dewi L. memperbarui anggaran di',
    target: 'Rencana Anggaran Event Webinar',
    time: DateTime.now().subtract(const Duration(hours: 5)), // Hari ini
    type: ActivityType.memo,
  ),
  Activity(
    initials: 'FS',
    action: 'Fahmi S. bergabung ke dalam workspace',
    target: 'Proyek PPB Mobile',
    time: DateTime.now().subtract(const Duration(seconds: 30)), // Hari ini
    type: ActivityType.memo,
  ),
  Activity(
    initials: 'AP',
    action: 'Andi P. meninggalkan komentar pada',
    target: 'Feedback Desain Figma dari Klien',
    time: DateTime.now().subtract(const Duration(days: 1)), // Kemarin
    type: ActivityType.comment,
  ),
  Activity(
    initials: 'KT',
    action: 'Koordinator TA mengubah lampiran pada',
    target: 'Pembagian Kelompok Tugas Akhir',
    time: DateTime.now().subtract(const Duration(days: 1, hours: 2)), // Kemarin
    type: ActivityType.file,
  ),
  Activity(
    initials: 'DL',
    action: 'DevOps Lead memperbarui file environment',
    target: 'Credential Environment Staging',
    time: DateTime.now().subtract(const Duration(days: 1, hours: 5)), // Kemarin
    type: ActivityType.file,
  ),
  Activity(
    initials: 'RER',
    action: 'DevOps Lead memperbarui file environment',
    target: 'Credential Environment Staging',
    time: DateTime.now().subtract(const Duration(days: 3, hours: 5)), // Kemarin
    type: ActivityType.file,
  ),
];
