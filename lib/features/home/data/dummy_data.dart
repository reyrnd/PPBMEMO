import '../../workspace/models/workspace.dart';
import '../../memo/models/memo.dart';
import '../../activity/models/activity.dart';

const dummyWorkspaces = [
  Workspace(
    id: '1',
    category: 'Kuliah',
    title: 'Proyek PPB',
    memoCount: 12,
    fileCount: 5,
    hasPin: true,
    time: '2 jam lalu',
    memberInitials: ['F', 'S'],
  ),
  Workspace(
    id: '2',
    category: 'Organisasi',
    title: 'Rapat Mingguan',
    memoCount: 8,
    fileCount: 2,
    hasPin: true,
    time: 'Kemarin',
    memberInitials: ['N', 'A'],
  ),
  Workspace(
    id: '3',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 2,
    fileCount: 5,
    hasPin: true,
    time: 'Kemarin',
    memberInitials: ['S', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
  Workspace(
    id: '4',
    category: 'memoSpace',
    title: 'Rapat Mingguan',
    memoCount: 1,
    fileCount: 3,
    time: 'Kemarin',
    memberInitials: ['R', 'R'],
  ),
];

const dummyMemos = [
  Memo(
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
    category: 'Proyek Robot AUV',
    title: 'Catatan Rapat Tim: Pembagian Modul Sensor',
    content:
        'Pengujian sensor sonar bawah air dijadwalkan hari Jumat di kolam rekayasa. Pastikan modul ESP32 dan waterproof...',
    fileName: 'spek_sonar_v2.pdf',
    author: 'Farhan K.',
    time: '25 mnt lalu',
    isPinned: true,
  ),
];

const dummyActivities = [
  Activity(
    initials: 'NP',
    action: 'Nabila P. menandai selesai pada',
    target: 'Rancangan UI Login',
    time: '10 menit lalu',
  ),
  Activity(
    initials: 'RR',
    action: 'Reynard R. menandai selesai pada',
    target: 'Rancangan UI dashboard',
    time: '20 menit lalu',
  ),
  Activity(
    initials: 'RR',
    action: 'Reynard R. menandai selesai pada',
    target: 'Rancangan UI dashboard',
    time: '20 menit lalu',
  ),
];
