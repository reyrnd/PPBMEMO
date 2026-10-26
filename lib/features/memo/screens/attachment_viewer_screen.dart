import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/attachment.dart';

class AttachmentViewerScreen extends StatefulWidget {
  final Attachment attachment;
  final VoidCallback? onDownload;

  const AttachmentViewerScreen({
    super.key,
    required this.attachment,
    this.onDownload,
  });

  @override
  State<AttachmentViewerScreen> createState() => _AttachmentViewerScreenState();
}

class _AttachmentViewerScreenState extends State<AttachmentViewerScreen> {
  var _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.viewerBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.viewerBackground,
        foregroundColor: AppTheme.viewerForeground,
        title: Text(
          widget.attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.viewerForeground),
        ),
        actions: [
          IconButton(
            tooltip: 'Unduh berkas',
            onPressed: widget.onDownload,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    return switch (widget.attachment.type) {
      AttachmentType.photo => InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: const _Placeholder(
            icon: Icons.image_outlined,
            label: 'Pratinjau foto',
          ),
        ),
      AttachmentType.document => _buildDocumentPlaceholder(),
      AttachmentType.video => _buildVideoPlaceholder(),
    };
  }

  Widget _buildDocumentPlaceholder() {
    final pageCount = widget.attachment.pageCount ?? 12;
    final currentPage = pageCount >= 3 ? 3 : pageCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(
          child: Center(
            child: _Placeholder(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Pratinjau PDF',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            '$currentPage / $pageCount',
            style: const TextStyle(
              color: AppTheme.viewerForeground,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: _isPlaying ? 'Jeda video' : 'Putar video',
          onPressed: () => setState(() => _isPlaying = !_isPlaying),
          iconSize: 72,
          color: AppTheme.viewerForeground,
          icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text(
                '0:14',
                style: TextStyle(color: AppTheme.viewerForeground),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: LinearProgressIndicator(
                  value: 0.35,
                  backgroundColor: AppTheme.textSecondary,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.viewerForeground),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDuration(widget.attachment.durationSeconds ?? 42),
                style: const TextStyle(color: AppTheme.viewerForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Placeholder({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 72, color: AppTheme.viewerForeground),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: AppTheme.viewerForeground),
        ),
      ],
    );
  }
}
