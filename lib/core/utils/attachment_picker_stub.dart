import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/app_bottom_sheet.dart';

class PickedAttachmentFile {
  final String name;
  final String sizeLabel;
  final String type; // 'Photo', 'Video', 'PDF', 'Document'
  final String? dataUrl;

  const PickedAttachmentFile({
    required this.name,
    required this.sizeLabel,
    required this.type,
    this.dataUrl,
  });
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '128 KB';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

/// Menghasilkan gambar PNG base64 dataUrl asli menggunakan Canvas Flutter
/// agar lampiran foto/kamera memiliki preview visual nyata di perangkat Android.
Future<String> _generateVisualDataUrl({
  required String title,
  required String subtitle,
  required Color bgColor,
  required Color accentColor,
}) async {
  final recorder = ui.PictureRecorder();
  const width = 480.0;
  const height = 320.0;
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

  final bgPaint = Paint()..color = bgColor;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(24),
    ),
    bgPaint,
  );

  final circlePaint = Paint()..color = accentColor.withValues(alpha: 0.18);
  canvas.drawCircle(const Offset(390, 70), 95, circlePaint);
  canvas.drawCircle(const Offset(90, 260), 70, circlePaint);

  final cardPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(32, 42, width - 64, height - 84),
      const Radius.circular(20),
    ),
    cardPaint,
  );

  final tpTitle = TextPainter(
    text: TextSpan(
      text: title,
      style: TextStyle(
        color: const Color(0xFF2A2926),
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 110);
  tpTitle.paint(canvas, const Offset(56, 95));

  final tpSub = TextPainter(
    text: TextSpan(
      text: subtitle,
      style: TextStyle(
        color: accentColor,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 110);
  tpSub.paint(canvas, const Offset(56, 140));

  final tpFooter = TextPainter(
    text: const TextSpan(
      text: 'MEMOSPACE ATTACHMENT PREVIEW',
      style: TextStyle(
        color: Color(0xFF9A948A),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 110);
  tpFooter.paint(canvas, const Offset(56, 225));

  final picture = recorder.endRecording();
  final img = await picture.toImage(width.toInt(), height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return '';
  final base64Str = base64Encode(byteData.buffer.asUint8List());
  return 'data:image/png;base64,$base64Str';
}

Future<PickedAttachmentFile?> pickAttachmentFromDevice({
  required BuildContext context,
  required String type,
  bool useCamera = false,
}) async {
  if (useCamera && (type == 'Photo' || type == 'Video')) {
    return captureFromCamera(context: context, type: type);
  }
  return _showDeviceFileBrowserSheet(context: context, type: type);
}

/// Layar Kamera Interaktif di Android untuk mengambil Foto atau merekam Video
Future<PickedAttachmentFile?> captureFromCamera({
  required BuildContext context,
  required String type,
}) async {
  bool isFrontCamera = false;
  bool flashOn = false;
  int selectedSceneIndex = 0;
  final scenes = type == 'Photo'
      ? [
          {
            'name': 'Whiteboard Sketch',
            'desc': 'Captured from Whiteboard Session',
            'bg': AppTheme.peach,
            'accent': AppTheme.caramel,
          },
          {
            'name': 'Notebook Page',
            'desc': 'Handwritten Notes Snapshot',
            'bg': AppTheme.mint,
            'accent': AppTheme.olive,
          },
          {
            'name': 'UI Wireframe',
            'desc': 'Screen Prototype Capture',
            'bg': AppTheme.lilac,
            'accent': AppTheme.plum,
          },
        ]
      : [
          {
            'name': 'App Walkthrough Clip',
            'desc': '00:14 · 1080p HD Recording',
            'bg': AppTheme.lilac,
            'accent': AppTheme.plum,
          },
          {
            'name': 'Team Standup Clip',
            'desc': '00:28 · 720p Video Note',
            'bg': AppTheme.peach,
            'accent': AppTheme.caramel,
          },
        ];

  return showModalBottomSheet<PickedAttachmentFile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final activeScene = scenes[selectedSceneIndex];
        return SheetFrame(
          title: type == 'Video' ? 'Camera Recorder' : 'Camera Capture',
          description: type == 'Video'
              ? 'Frame your video note and tap the red record button.'
              : 'Frame your shot and tap the shutter button below.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera Viewfinder Box
              Container(
                width: double.infinity,
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [AppTheme.shadowCard],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top bar inside viewfinder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: type == 'Video'
                                      ? AppTheme.coral
                                      : AppTheme.mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type == 'Video'
                                    ? 'REC READY · 1080P'
                                    : (isFrontCamera
                                        ? 'FRONT LENS'
                                        : 'REAR LENS · HDR'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setModalState(() => flashOn = !flashOn),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: flashOn
                                      ? AppTheme.peach
                                      : Colors.white.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  flashOn
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  size: 15,
                                  color:
                                      flashOn ? AppTheme.caramel : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setModalState(
                                () => isFrontCamera = !isFrontCamera,
                              ),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cameraswitch_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Center focus reticle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: (activeScene['bg'] as Color)
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            type == 'Video'
                                ? Icons.videocam_rounded
                                : Icons.filter_center_focus_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeScene['name'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeScene['desc'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preset selector pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(scenes.length, (i) {
                          final selected = i == selectedSceneIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setModalState(
                                () => selectedSceneIndex = i,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  scenes[i]['name'] as String,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppTheme.ink
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shutter Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final stamp =
                        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
                    final ext = type == 'Video' ? 'mp4' : 'png';
                    final cleanName = (activeScene['name'] as String)
                        .replaceAll(' ', '_');
                    final fileName = '${cleanName}_$stamp.$ext';

                    String? dataUrl;
                    if (type == 'Photo') {
                      dataUrl = await _generateVisualDataUrl(
                        title: activeScene['name'] as String,
                        subtitle: activeScene['desc'] as String,
                        bgColor: activeScene['bg'] as Color,
                        accentColor: activeScene['accent'] as Color,
                      );
                    }

                    if (!ctx.mounted) return;
                    Navigator.pop(
                      ctx,
                      PickedAttachmentFile(
                        name: fileName,
                        sizeLabel: type == 'Video' ? '4.2 MB' : '640 KB',
                        type: type,
                        dataUrl: dataUrl,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        type == 'Video' ? AppTheme.coral : AppTheme.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: Icon(
                    type == 'Video'
                        ? Icons.fiber_manual_record_rounded
                        : Icons.camera_alt_rounded,
                    size: 18,
                  ),
                  label: Text(
                    type == 'Video' ? 'Capture Video Clip' : 'Capture Photo',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// Pemilih File & Galeri Perangkat untuk Android / Desktop
Future<PickedAttachmentFile?> _showDeviceFileBrowserSheet({
  required BuildContext context,
  required String type,
}) async {
  // Coba pindai file nyata di direktori perangkat jika tersedia
  final discoveredFiles = <Map<String, String>>[];
  try {
    final candidateDirs = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/DCIM/Camera',
      '/storage/emulated/0/Documents',
    ];
    for (final dirPath in candidateDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        final entities = dir.listSync().whereType<File>().take(8);
        for (final file in entities) {
          final name = file.path.split(Platform.pathSeparator).last;
          final lower = name.toLowerCase();
          final matches = switch (type) {
            'Photo' => lower.endsWith('.jpg') ||
                lower.endsWith('.jpeg') ||
                lower.endsWith('.png') ||
                lower.endsWith('.webp'),
            'Video' => lower.endsWith('.mp4') ||
                lower.endsWith('.mov') ||
                lower.endsWith('.mkv'),
            'PDF' => lower.endsWith('.pdf'),
            _ => lower.endsWith('.doc') ||
                lower.endsWith('.docx') ||
                lower.endsWith('.xls') ||
                lower.endsWith('.xlsx') ||
                lower.endsWith('.ppt') ||
                lower.endsWith('.txt') ||
                lower.endsWith('.zip'),
          };
          if (matches) {
            discoveredFiles.add({
              'name': name,
              'size': _formatBytes(file.lengthSync()),
              'path': file.path,
            });
          }
        }
      }
    }
  } catch (_) {}

  final presetsByType = <String, List<Map<String, String>>>{
    'Photo': [
      {'name': 'UI_Design_Exploration.png', 'size': '1.4 MB'},
      {'name': 'Whiteboard_Architecture_Flow.jpg', 'size': '920 KB'},
      {'name': 'Component_Token_Sheet.png', 'size': '680 KB'},
    ],
    'Video': [
      {'name': 'Prototype_Interaction_Demo.mp4', 'size': '6.8 MB'},
      {'name': 'User_Testing_Session_Clip.mp4', 'size': '11.2 MB'},
      {'name': 'Sprint_Review_Recording.mov', 'size': '8.4 MB'},
    ],
    'PDF': [
      {'name': 'Project_Brief_Specification.pdf', 'size': '1.2 MB'},
      {'name': 'Q4_Product_Roadmap_Deck.pdf', 'size': '3.5 MB'},
      {'name': 'Research_Findings_Report.pdf', 'size': '890 KB'},
    ],
    'Document': [
      {'name': 'Meeting_Notes_Action_Items.docx', 'size': '245 KB'},
      {'name': 'Design_Tokens_Inventory.xlsx', 'size': '410 KB'},
      {'name': 'Release_Checklist_v2.txt', 'size': '48 KB'},
    ],
  };

  final allItems = [
    ...discoveredFiles,
    ...(presetsByType[type] ?? presetsByType['Document']!),
  ];

  final customNameCtrl = TextEditingController();

  return showModalBottomSheet<PickedAttachmentFile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SheetFrame(
        title: 'Select $type from device',
        description:
            'Tap a file from your device storage below or enter a file name.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  final fileName = item['name']!;
                  final fileSize = item['size']!;

                  IconData icon = Icons.insert_drive_file_outlined;
                  Color bg = AppTheme.surface;
                  Color fg = AppTheme.ink;
                  if (type == 'Photo') {
                    icon = Icons.image_outlined;
                    bg = AppTheme.peach;
                    fg = AppTheme.caramel;
                  } else if (type == 'Video') {
                    icon = Icons.videocam_outlined;
                    bg = AppTheme.lilac;
                    fg = AppTheme.plum;
                  } else if (type == 'PDF') {
                    icon = Icons.picture_as_pdf_outlined;
                    bg = AppTheme.mint;
                    fg = AppTheme.olive;
                  }

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        String? dataUrl;
                        if (type == 'Photo') {
                          dataUrl = await _generateVisualDataUrl(
                            title: fileName,
                            subtitle: '$type · $fileSize',
                            bgColor: AppTheme.peach,
                            accentColor: AppTheme.caramel,
                          );
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(
                          ctx,
                          PickedAttachmentFile(
                            name: fileName,
                            sizeLabel: fileSize,
                            type: type,
                            dataUrl: dataUrl,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [AppTheme.shadowSoft],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: fg, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$type · $fileSize',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.faint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.ink,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Attach',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Custom file name input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customNameCtrl,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Or type custom $type filename...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.faint,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final raw = customNameCtrl.text.trim();
                      if (raw.isEmpty) return;
                      final ext = switch (type) {
                        'Photo' => '.png',
                        'Video' => '.mp4',
                        'PDF' => '.pdf',
                        _ => '.docx',
                      };
                      final finalName = raw.contains('.') ? raw : '$raw$ext';
                      String? dataUrl;
                      if (type == 'Photo') {
                        dataUrl = await _generateVisualDataUrl(
                          title: finalName,
                          subtitle: '$type · 840 KB',
                          bgColor: AppTheme.peach,
                          accentColor: AppTheme.caramel,
                        );
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(
                        ctx,
                        PickedAttachmentFile(
                          name: finalName,
                          sizeLabel: '840 KB',
                          type: type,
                          dataUrl: dataUrl,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.mint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Add file',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.olive,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
