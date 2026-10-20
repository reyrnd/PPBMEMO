import 'package:flutter/material.dart';
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
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFF4F5F7),
          child: Text(activity.initials,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ),
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
              Text(activity.time,
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
        )
      ],
    );
  }
}
