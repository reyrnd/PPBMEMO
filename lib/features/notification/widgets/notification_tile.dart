import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/user_avatar.dart';
import 'package:memospace/features/notification/models/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final actorName = notification.actorName;
    final remainingAction =
        actorName != null && notification.action.startsWith(actorName)
            ? notification.action.substring(actorName.length)
            : notification.action;

    return Material(
      color: notification.isUnread
          ? AppTheme.editorToolbarBackground
          : AppTheme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(notification.initials, 18),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                        children: [
                          if (actorName != null)
                            TextSpan(
                              text: actorName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          TextSpan(text: remainingAction),
                          TextSpan(
                            text: notification.target,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.workspaceName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormatter.getRelativeTimeText(notification.time),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (notification.type == 'invitation') ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: onAccept,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.background,
                              minimumSize: const Size(0, 36),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Terima'),
                          ),
                          OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textPrimary,
                              minimumSize: const Size(0, 36),
                              side: const BorderSide(color: AppTheme.border),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (notification.isUnread) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.circle,
                    size: 7,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
