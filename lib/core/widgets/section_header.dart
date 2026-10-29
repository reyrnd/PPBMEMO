import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? badge;
  final String actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.badge,
    this.actionLabel = 'Lihat semua',
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge!,
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
