import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/date_formatter.dart';
import 'package:memospace/core/widgets/avatar_stack.dart';
import '../models/workspace.dart';

class WorkspaceCard extends StatelessWidget {
  final Workspace workspace;
  const WorkspaceCard({super.key, required this.workspace});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(workspace.category,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ),
              if (workspace.hasPin)
                const Icon(Icons.push_pin,
                    size: 14, color: AppTheme.textPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(workspace.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('📁 ${workspace.memoCount}  •  📄 ${workspace.fileCount}',
              style: const TextStyle(fontSize: 11, color: Colors.black38)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AvatarStack(workspace.memberInitials),
              Text(DateFormatter.getRelativeTimeText(workspace.updatedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          )
        ],
      ),
    );
  }
}
