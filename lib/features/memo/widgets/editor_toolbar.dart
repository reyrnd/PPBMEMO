import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/app_button.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback onPhoto;
  final VoidCallback onVideo;
  final VoidCallback onFile;
  final VoidCallback onChecklist;
  final VoidCallback onSave;

  const EditorToolbar({
    super.key,
    required this.onPhoto,
    required this.onVideo,
    required this.onFile,
    required this.onChecklist,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppTheme.editorToolbarBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToolbarAction(
            icon: Icons.image_outlined,
            tooltip: 'Tambah foto',
            onPressed: onPhoto,
          ),
          _ToolbarAction(
            icon: Icons.videocam_outlined,
            tooltip: 'Tambah video',
            onPressed: onVideo,
          ),
          _ToolbarAction(
            icon: Icons.attach_file,
            tooltip: 'Tambah berkas',
            onPressed: onFile,
          ),
          _ToolbarAction(
            icon: Icons.check_box_outlined,
            tooltip: 'Tambah checklist',
            onPressed: onChecklist,
          ),
          AppButton(
            label: 'Simpan',
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: AppTheme.textPrimary, size: 22),
    );
  }
}
