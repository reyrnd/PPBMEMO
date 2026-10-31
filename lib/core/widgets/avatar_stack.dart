import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../../features/workspace/models/workspace_member.dart';

class AvatarStack extends StatelessWidget {
  final List<String> initials;
  final double size;

  AvatarStack({
    super.key,
    List<String>? initials,
    List<dynamic>? members,
    int maxAvatars = 3,
    this.size = 28,
  }) : initials = initials ??
            (members != null
                ? members.take(maxAvatars).map((m) {
                    if (m is WorkspaceMember) return m.initials;
                    return m.toString();
                  }).toList()
                : const <String>[]);

  @override
  Widget build(BuildContext context) {
    if (initials.isEmpty) return const SizedBox.shrink();

    final tones = [
      AppTheme.ink,
      AppTheme.caramel,
      AppTheme.olive,
      AppTheme.soft
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(initials.length, (index) {
        final toneBg = tones[index % tones.length];
        final isDarkBg = toneBg == AppTheme.ink ||
            toneBg == AppTheme.caramel ||
            toneBg == AppTheme.olive;

        return Align(
          widthFactor: 0.65,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: toneBg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials[index],
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: isDarkBg ? Colors.white : AppTheme.muted,
              ),
            ),
          ),
        );
      }),
    );
  }
}
