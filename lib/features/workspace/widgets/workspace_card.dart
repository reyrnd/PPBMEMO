import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
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
              SizedBox(
                width: 12.0 * workspace.memberInitials.length + 8,
                height: 20,
                child: Stack(
                  children: [
                    for (var i = 0; i < workspace.memberInitials.length; i++)
                      Positioned(
                        left: i * 12.0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: i == 0 ? Colors.black : Colors.grey,
                          child: Text(
                            workspace.memberInitials[i],
                            style: const TextStyle(
                                fontSize: 8, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(workspace.time,
                  style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          )
        ],
      ),
    );
  }
}
