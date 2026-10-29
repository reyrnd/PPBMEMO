// create_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';

class CreateSheet extends StatelessWidget {
  const CreateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dekorasi container utama bottom sheet
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan konten
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis indikator kecil di paling atas sheet
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Judul Utama
          const Text(
            'Buat baru',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Menu Item
          _buildMenuItem(
            icon: Icons.notes_outlined,
            title: 'Catatan',
            subtitle: 'Tulis memo teks',
            onTap: () {
              final workspaces = context.read<WorkspaceCubit>().state;
              if (workspaces.isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Buat atau gabung workspace terlebih dahulu.'),
                  ),
                );
                return;
              }

              Navigator.of(context)
                ..pop()
                ..push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MemoEditorScreen(workspaceId: workspaces.first.id),
                  ),
                );
            },
          ),
          _buildMenuItem(
            icon: Icons.image_outlined,
            title: 'Foto',
            subtitle: 'Ambil atau pilih dari galeri',
            onTap: () {
              Navigator.pop(context);
              // Aksi untuk menambah foto
            },
          ),
          _buildMenuItem(
            icon: Icons.videocam_outlined,
            title: 'Video',
            subtitle: 'Rekam atau pilih dari galeri',
            onTap: () {
              Navigator.pop(context);
              // Aksi untuk menambah video
            },
          ),
          _buildMenuItem(
            icon: Icons.folder_open_outlined,
            title: 'Berkas',
            subtitle: 'PDF, dokumen, dan lainnya',
            onTap: () {
              Navigator.pop(context);
              // Aksi untuk menambah berkas
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat baris menu agar kode tetap rapi
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            // Container Ikon Abu-abu Soft
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1E1E1E), size: 24),
            ),
            const SizedBox(width: 16),
            // Teks Judul & Deskripsi Menu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
