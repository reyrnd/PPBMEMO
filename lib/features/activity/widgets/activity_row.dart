import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/user_avatar.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import '../../../core/app_theme.dart';
import '../models/activity.dart';

class ActivityRow extends StatelessWidget {
  final Activity activity;
  const ActivityRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(activity.initials, 14, color: AppTheme.surface),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13, height: 1.3),
                  children: [
                    TextSpan(text: '${activity.action} '),
                    TextSpan(
                        text: activity.target,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(DateFormatter.getRelativeTimeText(activity.time),
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
        )
      ],
    );
  }
}
