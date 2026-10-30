import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:memospace/features/memo/widgets/memo_card.dart';

class CanvasBoard extends StatefulWidget {
  final List<Memo> memos;
  final void Function(Memo memo, Offset position)? onMemoMoved;
  final ValueChanged<Memo>? onMemoTap;

  const CanvasBoard({
    super.key,
    required this.memos,
    this.onMemoMoved,
    this.onMemoTap,
  });

  @override
  State<CanvasBoard> createState() => _CanvasBoardState();
}

class _CanvasBoardState extends State<CanvasBoard> {
  static const _canvasSize = Size(2000, 1400);
  static const _cardSize = Size(260, 230);

  final _transformationController = TransformationController();
  final _viewportKey = GlobalKey();
  String? _draggingId;
  Offset? _dragPosition;
  Offset? _dragPointer;
  Timer? _autoPanTimer;
  var _scale = 1.0;

  @override
  void dispose() {
    _autoPanTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  Offset _initialPosition(int index) {
    const columns = 5;
    const horizontalSpacing = 310.0;
    const verticalSpacing = 280.0;
    return Offset(
      48 + (index % columns) * horizontalSpacing,
      48 + (index ~/ columns) * verticalSpacing,
    );
  }

  Offset _positionFor(int index, Memo memo) {
    if (_draggingId == memo.id && _dragPosition != null) return _dragPosition!;
    if (memo.boardX != null && memo.boardY != null) {
      return Offset(memo.boardX!, memo.boardY!);
    }
    return _initialPosition(index);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final nextScale = _transformationController.value.getMaxScaleOnAxis();
    setState(() => _scale = nextScale);
  }

  void _startMemoDrag(DragStartDetails details) {
    _dragPointer = details.globalPosition;
    _autoPanTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _autoPan(),
    );
  }

  void _updateMemoDrag(DragUpdateDetails details, Memo memo) {
    _dragPointer = details.globalPosition;
    _moveMemo(memo, details.delta);
  }

  void _cancelMemoDrag() {
    _dragPointer = null;
    _autoPanTimer?.cancel();
    _autoPanTimer = null;
    if (_draggingId != null || _dragPosition != null) {
      setState(() {
        _draggingId = null;
        _dragPosition = null;
      });
    }
  }

  void _autoPan() {
    final pointer = _dragPointer;
    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (pointer == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return;
    }

    const edgeSize = 48.0;
    const speedFactor = 0.2;
    final localPointer = renderObject.globalToLocal(pointer);
    final size = renderObject.size;

    double edgeDelta(double value, double extent) {
      if (value < edgeSize) {
        return (edgeSize - value).clamp(0.0, edgeSize) * speedFactor;
      }
      if (value > extent - edgeSize) {
        return -(value - (extent - edgeSize)).clamp(0.0, edgeSize) *
            speedFactor;
      }
      return 0;
    }

    final dx = edgeDelta(localPointer.dx, size.width);
    final dy = edgeDelta(localPointer.dy, size.height);
    if (dx == 0 && dy == 0) return;

    final matrix = _transformationController.value.clone();
    final scale = matrix.getMaxScaleOnAxis();
    matrix[12] =
        (matrix[12] + dx).clamp(size.width - _canvasSize.width * scale, 0.0);
    matrix[13] =
        (matrix[13] + dy).clamp(size.height - _canvasSize.height * scale, 0.0);
    _transformationController.value = matrix;
  }

  void _changeZoom(double factor) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final nextScale = (currentScale * factor).clamp(0.5, 3.0);
    final actualFactor = nextScale / currentScale;
    _transformationController.value = _transformationController.value.clone()
      ..scaleByDouble(actualFactor, actualFactor, 1, 1);
    setState(() => _scale = nextScale);
  }

  void _moveMemo(Memo memo, Offset delta) {
    final index = widget.memos.indexWhere((item) => item.id == memo.id);
    if (index < 0) return;

    final currentPosition = _positionFor(index, memo);
    final nextPosition = Offset(
      (currentPosition.dx + delta.dx / _scale)
          .clamp(0.0, _canvasSize.width - _cardSize.width),
      (currentPosition.dy + delta.dy / _scale)
          .clamp(0.0, _canvasSize.height - _cardSize.height),
    );

    setState(() {
      _draggingId = memo.id;
      _dragPosition = nextPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _viewportKey,
      children: [
        Positioned.fill(
          child: ClipRect(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 3,
              constrained: false,
              onInteractionEnd: _onInteractionEnd,
              child: SizedBox.fromSize(
                size: _canvasSize,
                child: CustomPaint(
                  painter: _DotGridPainter(),
                  child: Stack(
                    children: [
                      for (var index = 0; index < widget.memos.length; index++)
                        _buildMemoCard(index, widget.memos[index]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _buildZoomControls(),
        ),
      ],
    );
  }

  Widget _buildMemoCard(int index, Memo memo) {
    final position = _positionFor(index, memo);

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: _cardSize.width,
      child: GestureDetector(
        onPanStart: _startMemoDrag,
        onPanUpdate: (details) => _updateMemoDrag(details, memo),
        onPanEnd: (_) {
          final position = _dragPosition;
          if (position != null) widget.onMemoMoved?.call(memo, position);
          _cancelMemoDrag();
        },
        onPanCancel: _cancelMemoDrag,
        onTap: widget.onMemoTap == null ? null : () => widget.onMemoTap!(memo),
        child: Material(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: MemoCard(memo: memo),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Perkecil',
            onPressed: _scale > 0.5 ? () => _changeZoom(0.8) : null,
            icon: const Icon(Icons.remove),
          ),
          Text(
            '${(_scale * 100).round()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            tooltip: 'Perbesar',
            onPressed: _scale < 3 ? () => _changeZoom(1.25) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    const radius = 1.2;

    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
