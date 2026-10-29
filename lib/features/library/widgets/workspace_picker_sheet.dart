// workspace_picker_sheet.dart
import 'package:flutter/material.dart';
import 'package:memospace/features/workspace/models/workspace.dart';

class WorkspacePickerSheet extends StatefulWidget {
  final List<Workspace> workspaces; // daftar dari WorkspaceCubit
  final String? activeWorkspaceId; // null = "Semua workspace"

  const WorkspacePickerSheet({
    super.key,
    required this.workspaces,
    required this.activeWorkspaceId,
  });

  @override
  State<WorkspacePickerSheet> createState() => _WorkspacePickerSheetState();
}

class _WorkspacePickerSheetState extends State<WorkspacePickerSheet> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.activeWorkspaceId;
  }

  List<Map<String, dynamic>> get _workspaces => [
        <String, dynamic>{
          'id': null,
          'title': 'Semua workspace',
          'subtitle': 'Semua memo & berkas',
          'tag': null,
          'icon': Icons.widgets_outlined,
          'isDefault': true,
        },
        for (final w in widget.workspaces)
          <String, dynamic>{
            'id': w.id,
            'title': w.title,
            'subtitle': '${w.memberInitials.length} anggota',
            'tag': w.category,
            'icon': Icons.folder_outlined,
            'isDefault': false,
          },
      ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Garis Indikator Atas
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
          const SizedBox(height: 20),

          // 2. Judul Utama
          const Text(
            'Pilih workspace',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Daftar Opsi Workspace
          Material(
            color: Colors.transparent,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _workspaces.length,
              separatorBuilder: (context, index) {
                // Sesuai gambar: pembatas hanya untuk item non-default (dibawah "Semua workspace")
                if (index == 0) return const SizedBox(height: 12);
                return const Divider(
                    height: 1, thickness: 0.5, color: Color(0xFFE5E5E5));
              },
              itemBuilder: (context, index) {
                final item = _workspaces[index];
                final bool isSelected = _selectedId == item['id'];
                final bool isDefaultItem = item['isDefault'];

                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: isDefaultItem ? 0 : 4),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // Kustomisasi bentuk background abu-abu hanya untuk item default "Semua workspace"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: isDefaultItem
                        ? const Color(0xFFF4F5F7)
                        : Colors.transparent,

                    // Ikon Lingkaran Kiri
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: isDefaultItem
                          ? Colors.black
                          : const Color(0xFFF4F5F7),
                      child: Icon(
                        item['icon'],
                        color: isDefaultItem
                            ? Colors.white
                            : const Color(0xFF1E1E1E),
                        size: 20,
                      ),
                    ),

                    // Teks Tengah (Judul, Subtitle, & Tag Kategori)
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item['tag'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5F7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['tag'],
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      item['subtitle'],
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black45),
                    ),

                    // Tombol Indikator Kanan (Centang Hitam / Bulatan Kosong)
                    trailing: isSelected
                        ? (isDefaultItem
                            ? const CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.black,
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 14),
                              )
                            : const Icon(Icons.check_circle,
                                color: Color(0xFF1E1E1E), size: 22))
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF4F5F7),
                              border: Border.all(
                                  color: Colors.transparent, width: 0),
                            ),
                          ),
                    onTap: () {
                      setState(() => _selectedId = item['id']);
                      Navigator.pop(
                          context, {'id': item['id'], 'title': item['title']});
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
