import '../../memo/models/memo.dart';

const dummyMemos = [
  Memo(
    id: 'memo-01',
    category: 'Rekayasa Perangkat Lunak',
    title: 'Daftar User Story Sprint 2',
    content:
        'Integrasi autentikasi Google Sign-In dan perbaikan state management Riverpod untuk halaman profil dan...',
    taskCount: '8/10 tugas',
    author: 'Dimas A.',
    time: '3 jam lalu',
    isPinned: false,
    isBookmarked: true,
  ),
  Memo(
    id: 'memo-02',
    category: 'Proyek Robot AUV',
    title: 'Catatan Rapat Tim: Pembagian Modul Sensor',
    content:
        'Pengujian sensor sonar bawah air dijadwalkan hari Jumat di kolam rekayasa. Pastikan modul ESP32 dan waterproof...',
    fileName: 'spek_sonar_v2.pdf',
    author: 'Farhan K.',
    time: '25 mnt lalu',
    isPinned: true,
    isBookmarked: false, // Menyesuaikan opsional field
  ),
  Memo(
    id: 'memo-03',
    category: 'Kuliah',
    title: 'Kisi-Kisi UTS Pemrograman Mobile',
    content:
        'Pelajari materi seputar State Management (Provider/Riverpod), Custom Painter, Rest API Integration, dan local storage menggunakan Hive...',
    taskCount: '0/5 tugas',
    author: 'Dosen PPB',
    time: 'Kemarin',
    isPinned: true,
    isBookmarked: true,
  ),
  Memo(
    id: 'memo-04',
    category: 'memoSpace',
    title: 'Ide Konten Reels & TikTok',
    content:
        '1. Tutorial slicing UI Clean Architecture 60 detik. 2. Tips debugging error "RenderFlex overflowed". 3. Rekomendasi package UI tersembunyi...',
    author: 'Siti R.',
    time: '2 jam lalu',
    isPinned: false,
    isBookmarked: true,
  ),
  Memo(
    id: 'memo-05',
    category: 'Kerja',
    title: 'Feedback Desain Figma dari Klien',
    content:
        'Warna tombol primary diganti ke Hex #0284C7. Font size header di halaman dashboard terlalu besar, turunkan ke 20sp. Flow checkout dipersingkat...',
    fileName: 'feedback_rev_3.docx',
    author: 'Andi P.',
    time: '1 hari lalu',
    isPinned: false,
    isBookmarked: false,
  ),
  Memo(
    id: 'memo-06',
    category: 'Organisasi',
    title: 'Rencana Anggaran Event Webinar',
    content:
        'Total anggaran yang disetujui sebesar Rp 2.500.000. Alokasi dana untuk fee pembicara Rp 1.500.000, sisanya untuk publikasi ads dan doorprize...',
    taskCount: '3/4 tugas',
    author: 'Dewi L.',
    time: '5 jam lalu',
    isPinned: false,
    isBookmarked: false,
  ),
  Memo(
    id: 'memo-07',
    category: 'Pribadi',
    title: 'Daftar Belanja Bulanan',
    content:
        'Beli kopi beans Arabika, token listrik, isi ulang galon, deterjen, booster susu kucing, dan vitamin untuk stok 1 bulan...',
    taskCount: '4/12 tugas',
    author: 'Saya',
    time: 'Baru saja',
    isPinned: false,
    isBookmarked: false,
  ),
  Memo(
    id: 'memo-08',
    category: 'Kuliah',
    title: 'Pembagian Kelompok Tugas Akhir',
    content:
        'Kelompok 4 terdiri dari Dimas, Farhan, dan Siti. Topik yang diambil fokus pada optimasi IoT Core berbasis sistem terdistribusi dengan MQTT...',
    fileName: 'draft_proposal_ta.pdf',
    author: 'Koordinator TA',
    time: '2 hari lalu',
    isPinned: false,
    isBookmarked: true,
  ),
  Memo(
    id: 'memo-09',
    category: 'Kerja',
    title: 'Credential Environment Staging',
    content:
        'Base URL API Staging baru: https://workspace.id. Untuk secret key dan detail client-id silakan cek di file environment terlampir...',
    fileName: '.env.staging',
    author: 'DevOps Lead',
    time: '4 hari lalu',
    isPinned: true,
    isBookmarked: true,
  ),
  Memo(
    id: 'memo-10',
    category: 'Proyek Robot AUV',
    title: 'Daftar Komponen yang Harus Dibeli',
    content:
        'List belanja: Brushless motor 24V, ESC 40A, O-ring cadangan untuk watertight enclosure, dan kabel serabut lapis silikon tahan korosi air laut...',
    taskCount: '10/10 tugas',
    author: 'Farhan K.',
    time: 'Baru saja',
    isPinned: false,
    isBookmarked: false,
  ),
];
