import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

enum AppButtonVariant { filled, outline }

class AppButton extends StatelessWidget {
  final AppButtonVariant variant;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isLoading;

  const AppButton({
    super.key,
    this.variant = AppButtonVariant.filled,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = variant == AppButtonVariant.filled
        ? AppTheme.background
        : AppTheme.textPrimary;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (isLoading || icon != null) const SizedBox(width: 8),
        Text(label),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    );
    final button = variant == AppButtonVariant.filled
        ? FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: shape,
            ),
            child: content,
          )
        : OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: AppTheme.border),
              shape: shape,
            ),
            child: content,
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }
}
