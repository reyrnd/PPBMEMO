import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class AvatarStack extends StatelessWidget {
  final List<String> initials;
  final int maxVisible;
  final double radius;

  const AvatarStack(
    this.initials, {
    super.key,
    this.maxVisible = 3,
    this.radius = 10,
  })  : assert(maxVisible > 0),
        assert(radius > 0);

  static const double _offset = 12;

  @override
  Widget build(BuildContext context) {
    final visibleCount =
        initials.length < maxVisible ? initials.length : maxVisible;
    final overflowCount = initials.length - visibleCount;
    final hasOverflow = overflowCount > 0;
    final diameter = radius * 2;
    final itemCount = visibleCount + (hasOverflow ? 1 : 0);
    final width = itemCount == 0 ? 0.0 : diameter + (itemCount - 1) * _offset;

    return SizedBox(
      width: width,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < visibleCount; index++)
            Positioned(
              left: index * _offset,
              child: CircleAvatar(
                radius: radius,
                backgroundColor:
                    index == 0 ? AppTheme.primary : AppTheme.textSecondary,
                child: Text(
                  initials[index],
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (hasOverflow)
            Positioned(
              left: visibleCount * _offset,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: AppTheme.surface,
                child: Text(
                  '+$overflowCount',
                  maxLines: 1,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
