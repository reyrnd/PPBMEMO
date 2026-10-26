import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final Color? color;

  const UserAvatar(
    this.initials,
    this.radius, {
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color ?? AppTheme.primary,
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: AppTheme.background,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
