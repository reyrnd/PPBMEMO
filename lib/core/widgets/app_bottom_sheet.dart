import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  double? heightFactor,
  bool showCloseButton = false,
}) {
  assert(
    heightFactor == null || (heightFactor > 0 && heightFactor <= 1),
    'heightFactor must be greater than 0 and at most 1.',
  );

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final content = Column(
        mainAxisSize:
            heightFactor == null ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (title != null || showCloseButton) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                  ),
                if (showCloseButton)
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 20),
          if (heightFactor == null) child else Expanded(child: child),
        ],
      );

      final sheet = Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: heightFactor == null
            ? SingleChildScrollView(child: content)
            : content,
      );

      if (heightFactor == null) {
        return SafeArea(
          top: false,
          child: sheet,
        );
      }

      return SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * heightFactor,
          child: sheet,
        ),
      );
    },
  );
}
