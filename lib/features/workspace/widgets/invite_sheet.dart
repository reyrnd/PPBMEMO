import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class InviteSheet extends StatelessWidget {
  const InviteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data internal kode unik dari berkas TSX
    const String workspaceName = 'Northstar Studio';
    const String inviteCode = 'NORTH-24Q';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 16),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Indicator Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Header Panel Sheet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Invite teammates',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Share this unique code to join $workspaceName.',
                      style: TextStyle(
                          fontSize: 10, color: AppTheme.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.ink, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Dark Code Display Card (bg-ink)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.ink,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [AppTheme.shadowCard],
            ),
            child: Column(
              children: const [
                Text(
                  'WORKSPACE CODE',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.8),
                ),
                SizedBox(height: 12),
                Text(
                  inviteCode,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6.0),
                ),
                SizedBox(height: 8),
                Text(
                  'Codes are unique to each workspace.',
                  style: TextStyle(fontSize: 9, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Dual Action Buttons (Copy & Regenerate)
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy code',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'New code',
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Access Info Box Card (White Box Style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: AppTheme.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: AppTheme.muted, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Invite as member',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink)),
                      SizedBox(height: 2),
                      Text('New people can view, create, and edit memos.',
                          style: TextStyle(fontSize: 9, color: AppTheme.faint)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. Bottom Done Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Done',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: AppTheme.ink),
        label: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.ink,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          side: const BorderSide(color: AppTheme.line, width: 1),
        ),
      ),
    );
  }
}
