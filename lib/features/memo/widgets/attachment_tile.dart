import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/attachment.dart';

class AttachmentTile extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const AttachmentTile({
    super.key,
    required this.attachment,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (attachment.type == AttachmentType.document) {
      return _buildDocumentTile();
    }

    return _buildMediaTile();
  }

  Widget _buildMediaTile() {
    return SizedBox(
      width: 170,
      child: Material(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildThumbnail(),
                    if (attachment.type == AttachmentType.video)
                      const Positioned.fill(
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.textSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.play_arrow,
                                color: AppTheme.background,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (attachment.type == AttachmentType.video &&
                        attachment.durationSeconds != null)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDuration(attachment.durationSeconds!),
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    if (onRemove != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Material(
                          color: AppTheme.textPrimary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onRemove,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: AppTheme.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attachment.formattedSize,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final isVideo = attachment.type == AttachmentType.video;
    final placeholderColor =
        isVideo ? AppTheme.textSecondary : AppTheme.surface;

    return SizedBox(
      height: 105,
      width: double.infinity,
      child: attachment.url.isEmpty
          ? ColoredBox(
              color: placeholderColor,
              child: Icon(
                isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                color: isVideo ? AppTheme.background : AppTheme.textSecondary,
                size: 30,
              ),
            )
          : Image.network(
              attachment.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: placeholderColor,
                child: Icon(
                  isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                  color: isVideo ? AppTheme.background : AppTheme.textSecondary,
                  size: 30,
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentTile() {
    return SizedBox(
      width: 240,
      child: Material(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _documentIcon,
                  size: 32,
                  color: AppTheme.textPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attachment.formattedSize,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 18),
                    color: AppTheme.textSecondary,
                    tooltip: 'Hapus lampiran',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _documentIcon {
    final extension = attachment.name.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
