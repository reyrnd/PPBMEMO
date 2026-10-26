import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class WorkspaceMenu extends StatelessWidget {
  final bool isPinned;
  final bool isOwner;
  final VoidCallback? onTogglePin;
  final VoidCallback? onRename;
  final VoidCallback? onLeave;
  final VoidCallback? onDelete;

  const WorkspaceMenu({
    super.key,
    required this.isPinned,
    required this.isOwner,
    this.onTogglePin,
    this.onRename,
    this.onLeave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_WorkspaceAction>(
      tooltip: 'Menu workspace',
      // Menggunakan ikon tiga titik dalam lingkaran yang serasi dengan desain luar
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.more_vert, color: AppTheme.textPrimary, size: 22),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 6, // Memberikan bayangan halus seperti di gambar referensi
      offset: const Offset(
          0, 52), // Menggeser posisi pop-up tepat di bawah tombol menu
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24), // Sudut melengkung lebar dan halus
      ),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _WorkspaceAction.togglePin,
          enabled: onTogglePin != null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: _MenuLabel(
            icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin_outlined,
            label: isPinned ? 'Lepas sematan' : 'Sematkan',
          ),
        ),
        PopupMenuItem(
          value: _WorkspaceAction.rename,
          enabled: onRename != null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: const _MenuLabel(
            icon: Icons.edit_outlined,
            label: 'Ubah nama',
          ),
        ),
        PopupMenuItem(
          value: _WorkspaceAction.leave,
          enabled: onLeave != null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: const _MenuLabel(
            icon: Icons.logout, // Diubah ke ikon log out sesuai visual gambar
            label: 'Keluar dari workspace',
            color: Color(0xFFB91C1C), // Merah gelap pekat
          ),
        ),
        if (isOwner) ...[
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: _WorkspaceAction.delete,
            enabled: onDelete != null,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.delete_outline,
                    size: 20, color: Color(0xFFB91C1C)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hapus workspace',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'khusus pemilik',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _WorkspaceAction action,
  ) async {
    switch (action) {
      case _WorkspaceAction.togglePin:
        onTogglePin?.call();
      case _WorkspaceAction.rename:
        onRename?.call();
      case _WorkspaceAction.leave:
        onLeave?.call();
      case _WorkspaceAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Hapus workspace?'),
            content: const Text(
              'Workspace dan seluruh isinya akan dihapus. Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
        if (confirmed == true) onDelete?.call();
    }
  }
}

enum _WorkspaceAction { togglePin, rename, leave, delete }

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuLabel({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? AppTheme.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 20, color: foregroundColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
