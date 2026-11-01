import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../search/screens/search_screen.dart';
import '../../workspace/cubit/workspace_cubit.dart';
import '../../workspace/models/workspace.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _language = 'English';
  final _authService = AuthService();

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ME';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Naya Anindita';
    final userEmail = user?.email ?? 'naya@memospace.app';
    final initials = _getInitials(userName);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.ink,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await FirebaseAuth.instance.currentUser?.reload();
            if (!mounted) return;
            await Future.wait([
              context.read<WorkspaceCubit>().refresh(),
              context.read<MemoCubit>().refresh(),
            ]);
            if (mounted) setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header Akun & Pengaturan
                _buildHeader(context),
                const SizedBox(height: 20),

                // Main Profile Card (Dark/Ink Style Sesuai App.tsx)
                _buildMainProfileCard(userName, userEmail, initials),
                const SizedBox(height: 20),

                // Statistics Info Bar
                _buildStatsGrid(),
                const SizedBox(height: 28),

                // Preferences Section Title
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Menu List Container
                _buildPreferencesMenu(context),
                const SizedBox(height: 20),

                // Promo Upgrade Subscription Card (Mint Style Sesuai App.tsx)
                _buildUpgradePromoCard(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Widgets / Component Slicing
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT & SETTINGS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppTheme.muted,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your profile',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowSoft],
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: AppTheme.ink, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => showNotificationsSheet(context: context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowSoft],
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppTheme.ink, size: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainProfileCard(String name, String email, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [AppTheme.shadowCard],
      ),
      child: Column(
        children: [
          // Big Avatar Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 4,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),
          // Edit Profile Button -> Buka EditProfileSheet (Bottom Sheet)
          ElevatedButton(
            onPressed: () => showEditProfileSheet(
              context: context,
              onProfileUpdated: () => setState(() {}),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.12),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Edit profile',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return BlocBuilder<MemoCubit, MemoState>(
      builder: (context, memoState) {
        final memos = memoState is MemoLoaded ? memoState.memos : const [];
        final memoCount = memos.length;

        return BlocBuilder<WorkspaceCubit, List<Workspace>>(
          builder: (context, workspaces) {
            final spaceCount = workspaces.length;
            final sharedSpaceIds = workspaces
                .where((w) => w.members.length > 1)
                .map((w) => w.id)
                .toSet();
            final sharedCount = memos
                .where((m) =>
                    sharedSpaceIds.contains(m.workspaceId) ||
                    m.attachments.isNotEmpty ||
                    m.checklist.isNotEmpty)
                .length;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatItem('$memoCount', 'Memos')),
                  Container(width: 1, height: 24, color: AppTheme.line),
                  Expanded(
                      child: _buildStatItem('$spaceCount', 'Spaces')),
                  Container(width: 1, height: 24, color: AppTheme.line),
                  Expanded(
                      child: _buildStatItem('$sharedCount', 'Shared')),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.faint,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        children: [
          // 1. Account Settings -> Bottom Sheet
          _buildMenuRow(
            context,
            Icons.settings_outlined,
            'Account settings',
            isFirst: true,
            onTap: () => showAccountSettingsSheet(
              context: context,
              onLogout: _logout,
            ),
          ),
          // 2. Notifications -> Bottom Sheet
          _buildMenuRow(
            context,
            Icons.notifications_none_rounded,
            'Notifications',
            trailingValue: 'On',
            onTap: () => showNotificationSettingsSheet(context: context),
          ),
          // 3. Language -> Bottom Sheet
          _buildMenuRow(
            context,
            Icons.language_rounded,
            'Language',
            trailingValue: _language,
            onTap: () => showLanguageSheet(
              context: context,
              currentLanguage: _language,
              onSelected: (lang) => setState(() => _language = lang),
            ),
          ),
          // 4. Help & feedback -> Bottom Sheet
          _buildMenuRow(
            context,
            Icons.chat_bubble_outline_rounded,
            'Help & feedback',
            onTap: () => showActionSheet(
              context: context,
              title: 'Help & feedback',
              description: 'How can we help you today?',
              options: [
                'Getting started with MemoSpace',
                'Working with team workspaces',
                'Memos, boards and attachments',
                'Contact customer support',
              ],
              primaryButtonLabel: 'Done',
            ),
          ),
          // 5. Sign out
          _buildMenuRow(
            context,
            Icons.logout_rounded,
            'Sign out',
            iconColor: AppTheme.danger,
            textColor: AppTheme.danger,
            isLast: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailingValue,
    Color? iconColor,
    Color? textColor,
    bool isFirst = false,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.line, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(24) : Radius.zero,
            bottom: isLast ? const Radius.circular(24) : Radius.zero,
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppTheme.muted, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppTheme.ink,
                    ),
                  ),
                ),
                if (trailingValue != null) ...[
                  Text(
                    trailingValue,
                    style: const TextStyle(fontSize: 11, color: AppTheme.faint),
                  ),
                  const SizedBox(width: 4),
                ],
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.faint, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradePromoCard(BuildContext context) {
    return InkWell(
      onTap: () => showUpgradeSheet(context: context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.mint,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [AppTheme.shadowSoft],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.olive, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MemoSpace Plus',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Unlock unlimited shared spaces',
                    style: TextStyle(fontSize: 10, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.muted, size: 18),
          ],
        ),
      ),
    );
  }
}
