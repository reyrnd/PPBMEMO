import '../models/app_notification.dart'; // Sesuaikan path model di atas

final List<AppNotification> dummyNotifications = [
  // --- HARI INI ---
  AppNotification(
    initials: 'FA',
    actorName: 'Farhan',
    action: 'Farhan mengomentari memo ',
    target: 'Hasil Uji Baterai LiPo',
    workspaceName: 'Proyek Robot AUV',
    time: DateTime.now().subtract(const Duration(minutes: 15)),
    isUnread: true,
  ),
  AppNotification(
    initials: 'RR',
    actorName: 'Rafi Ramadhan',
    action: 'Rafi Ramadhan mengundang kamu bergabung ke workspace ',
    target: 'Lab Sensor Oseanografi',
    workspaceName: 'Lab Sensor',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    isUnread: true,
    type: 'invitation', // Tipe khusus untuk menampilkan tombol Terima/Tolak
  ),
  AppNotification(
    initials: 'NA',
    actorName: 'Nabila',
    action: 'Nabila menyebut kamu di Rancangan UI Login: ',
    target: '"Tolong cek skema warna dark-line..."',
    workspaceName: 'Proyek PPB',
    time: DateTime.now().subtract(const Duration(hours: 3)),
    isUnread: true,
  ),

  // --- KEMARIN ---
  AppNotification(
    initials: 'DA',
    actorName: 'Dimas Aditya',
    action: 'Dimas Aditya menugaskan kamu pada tugas ',
    target: 'Kalibrasi Sensor Sonar 200kHz',
    workspaceName: 'Proyek Robot AUV',
    time: DateTime.now()
        .subtract(const Duration(days: 1, hours: 2)), // Kemarin sore
    isUnread: false,
  ),
  AppNotification(
    initials: 'DA',
    actorName: 'Dimas Aditya',
    action: 'Dimas Aditya menugaskan kamu pada tugas ',
    target: 'Kalibrasi Sensor Sonar 200kHz',
    workspaceName: 'Proyek Robot AUV',
    time: DateTime.now()
        .subtract(const Duration(days: 1, hours: 2)), // Kemarin sore
    isUnread: false,
  ),
  AppNotification(
    initials: 'SN',
    actorName: 'Siti Nurhaliza',
    action: 'Siti Nurhaliza mengunggah berkas baru ',
    target: 'Skematik_PCB_Rev2.pdf',
    workspaceName: 'Proyek PPB',
    time: DateTime.now()
        .subtract(const Duration(days: 1, hours: 7)), // Kemarin siang
    isUnread: false,
  ),
  AppNotification(
    initials: 'FA',
    actorName: 'Farhan',
    action: 'Farhan menyelesaikan checklist ',
    target: 'Pemeriksaan Pin GPIO ESP32',
    workspaceName: 'Proyek Robot AUV',
    time: DateTime.now()
        .subtract(const Duration(days: 1, hours: 9)), // Kemarin pagi
    isUnread: false,
  ),
];
