// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'attachment_picker_stub.dart' as stub;

export 'attachment_picker_stub.dart' show PickedAttachmentFile;

String _formatBytes(int bytes) {
  if (bytes <= 0) return '1 KB';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

Future<stub.PickedAttachmentFile?> pickAttachmentFromDevice({
  required BuildContext context,
  required String type,
  bool useCamera = false,
}) async {
  if (useCamera && (type == 'Photo' || type == 'Video')) {
    final cameraResult = await captureFromCamera(context: context, type: type);
    if (cameraResult != null) return cameraResult;
  }

  final completer = Completer<stub.PickedAttachmentFile?>();
  final uploadInput = html.FileUploadInputElement();

  switch (type) {
    case 'Photo':
      uploadInput.accept = 'image/*';
      break;
    case 'Video':
      uploadInput.accept = 'video/*';
      break;
    case 'PDF':
      uploadInput.accept = '.pdf,application/pdf';
      break;
    case 'Document':
    default:
      uploadInput.accept =
          '.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.md,.json,.zip,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      break;
  }

  uploadInput.style.display = 'none';
  html.document.body?.append(uploadInput);

  bool completed = false;

  uploadInput.onChange.listen((event) {
    if (completed) return;
    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      completed = true;
      uploadInput.remove();
      completer.complete(null);
      return;
    }

    final file = files.first;
    final sizeLabel = _formatBytes(file.size);

    if (type == 'Photo' && file.size < 2500 * 1024) {
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        if (!completed) {
          completed = true;
          uploadInput.remove();
          completer.complete(
            stub.PickedAttachmentFile(
              name: file.name,
              sizeLabel: sizeLabel,
              type: type,
              dataUrl: reader.result as String?,
            ),
          );
        }
      });
      reader.onError.listen((_) {
        if (!completed) {
          completed = true;
          uploadInput.remove();
          completer.complete(
            stub.PickedAttachmentFile(
              name: file.name,
              sizeLabel: sizeLabel,
              type: type,
            ),
          );
        }
      });
      reader.readAsDataUrl(file);
    } else {
      completed = true;
      uploadInput.remove();
      completer.complete(
        stub.PickedAttachmentFile(
          name: file.name,
          sizeLabel: sizeLabel,
          type: type,
        ),
      );
    }
  });

  uploadInput.click();
  return completer.future;
}

Future<stub.PickedAttachmentFile?> captureFromCamera({
  required BuildContext context,
  required String type,
}) async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) {
    return stub.captureFromCamera(context: context, type: type);
  }

  html.MediaStream? stream;
  try {
    stream = await mediaDevices.getUserMedia({
      'video': {'facingMode': 'environment'},
      'audio': type == 'Video',
    });
  } catch (_) {
    try {
      stream = await mediaDevices.getUserMedia({'video': true});
    } catch (_) {
      if (!context.mounted) return null;
      return stub.captureFromCamera(context: context, type: type);
    }
  }

  final completer = Completer<stub.PickedAttachmentFile?>();
  final activeStream = stream;

  void stopStream() {
    for (final track in activeStream.getTracks()) {
      track.stop();
    }
  }

  final overlay = html.DivElement()
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100vw'
    ..style.height = '100vh'
    ..style.backgroundColor = 'rgba(20, 20, 19, 0.92)'
    ..style.zIndex = '999999'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.fontFamily = 'Manrope, sans-serif';

  final card = html.DivElement()
    ..style.backgroundColor = '#F6F3EE'
    ..style.borderRadius = '28px'
    ..style.padding = '20px'
    ..style.width = '90%'
    ..style.maxWidth = '420px'
    ..style.boxShadow = '0 24px 60px rgba(0,0,0,0.4)'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center';

  final titleEl = html.DivElement()
    ..text = type == 'Video' ? 'Record Video' : 'Take Photo'
    ..style.fontSize = '18px'
    ..style.fontWeight = '800'
    ..style.color = '#181816'
    ..style.marginBottom = '4px';

  final subEl = html.DivElement()
    ..text = type == 'Video'
        ? 'Camera is active. Click Capture Video Clip when ready.'
        : 'Camera is active. Frame your shot and click Capture Photo.'
    ..style.fontSize = '12px'
    ..style.color = '#6B6A65'
    ..style.marginBottom = '14px'
    ..style.textAlign = 'center';

  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..setAttribute('playsinline', 'true')
    ..style.width = '100%'
    ..style.maxHeight = '320px'
    ..style.objectFit = 'cover'
    ..style.borderRadius = '20px'
    ..style.backgroundColor = '#181816';
  video.srcObject = activeStream;

  final btnRow = html.DivElement()
    ..style.display = 'flex'
    ..style.gap = '10px'
    ..style.width = '100%'
    ..style.marginTop = '16px';

  final cancelBtn = html.ButtonElement()
    ..text = 'Cancel'
    ..style.flex = '1'
    ..style.padding = '12px 16px'
    ..style.borderRadius = '999px'
    ..style.border = 'none'
    ..style.backgroundColor = '#EFECE6'
    ..style.color = '#181816'
    ..style.fontWeight = '700'
    ..style.fontSize = '13px'
    ..style.cursor = 'pointer';

  final captureBtn = html.ButtonElement()
    ..text = type == 'Video' ? 'Capture Video Clip' : 'Capture Photo'
    ..style.flex = '2'
    ..style.padding = '12px 16px'
    ..style.borderRadius = '999px'
    ..style.border = 'none'
    ..style.backgroundColor = '#181816'
    ..style.color = '#FFFFFF'
    ..style.fontWeight = '700'
    ..style.fontSize = '13px'
    ..style.cursor = 'pointer';

  cancelBtn.onClick.listen((_) {
    stopStream();
    overlay.remove();
    if (!completer.isCompleted) completer.complete(null);
  });

  captureBtn.onClick.listen((_) {
    final w = video.videoWidth > 0 ? video.videoWidth : 640;
    final h = video.videoHeight > 0 ? video.videoHeight : 480;
    final canvas = html.CanvasElement(width: w, height: h);
    canvas.context2D.drawImageScaled(video, 0, 0, w, h);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.82);

    stopStream();
    overlay.remove();

    final timestamp = DateTime.now();
    final timeCode =
        '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
    final fileName = type == 'Video'
        ? 'Camera_Video_$timeCode.mp4'
        : 'Camera_Photo_$timeCode.jpg';
    final approxBytes = (dataUrl.length * 0.75).round();

    if (!completer.isCompleted) {
      completer.complete(
        stub.PickedAttachmentFile(
          name: fileName,
          sizeLabel: _formatBytes(approxBytes),
          type: type,
          dataUrl: dataUrl,
        ),
      );
    }
  });

  btnRow.append(cancelBtn);
  btnRow.append(captureBtn);
  card.append(titleEl);
  card.append(subEl);
  card.append(video);
  card.append(btnRow);
  overlay.append(card);
  html.document.body?.append(overlay);

  return completer.future;
}
