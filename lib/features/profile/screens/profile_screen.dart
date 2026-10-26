import 'package:flutter/material.dart';
import 'package:memospace/core/app_routes.dart';
import 'package:memospace/features/auth/models/app_user.dart';
import 'package:memospace/features/notification/screens/notification_settings_screen.dart';
import 'package:memospace/features/profile/screens/change_password_screen.dart';
import 'package:memospace/features/profile/screens/edit_profile_screen.dart';
import 'package:memospace/features/profile/screens/help_screen.dart';
import 'package:memospace/features/profile/screens/language_screen.dart';
import 'package:memospace/core/widgets/user_avatar.dart';
import 'package:memospace/services/auth_service.dart';
import '../../../core/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _user = AppUser(
    id: 'user-dimas',
    name: 'Dimas A.',
    email: 'dimas@student.example.ac.id',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // DIUBAH: Properti actions dihapus sepenuhnya di sini untuk menghilangkan tombol avatar redundan
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // --- 2. FOTO PROFIL DENGAN BADGE VERIFIKASI ---
              Stack(
                children: [
                  const UserAvatar('DA', 45),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF22C55E),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 3. NAMA DAN EMAIL ---
              const Text(
                'Dimas A.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'dimas@student.example.ac.id',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. TOMBOL EDIT PROFIL ---
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(user: _user),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined,
                    size: 16, color: AppTheme.textPrimary),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 24),

              // --- 5. GRID STATISTIK METER (WORKSPACE & MEMO) ---
              Row(
                children: [
                  Expanded(child: _buildStatCard('4', 'Workspace')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('27', 'Memo')),
                ],
              ),
              const SizedBox(height: 24),

              // --- 6. GRUP MENU: AKUN ---
              _buildSectionHeader('AKUN'),
              _buildMenuCard([
                _buildMenuItem(
                  Icons.person_outline,
                  'Informasi Pribadi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(user: _user),
                    ),
                  ),
                ),
                _buildMenuItem(
                  Icons.lock_open_outlined,
                  'Ubah Kata Sandi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // --- 7. GRUP MENU: PREFERENSI ---
              _buildSectionHeader('PREFERENSI'),
              _buildMenuCard([
                _buildMenuItem(
                  Icons.notifications_none_outlined,
                  'Notifikasi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  ),
                ),
                _buildMenuItem(
                  Icons.language_outlined,
                  'Bahasa',
                  trailingText: 'Indonesia',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // --- 8. GRUP MENU: TENTANG ---
              _buildSectionHeader('TENTANG'),
              _buildMenuCard([
                _buildMenuItem(
                  Icons.help_outline_outlined,
                  'Bantuan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  ),
                ),
                _buildMenuItem(
                  Icons.info_outline_rounded,
                  'Versi Aplikasi',
                  trailingText: '1.0.0',
                  showArrow: false,
                ),
              ]),
              const SizedBox(height: 32),

              // --- 9. TOMBOL KELUAR ---
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (r) => false);
                },
                icon: const Icon(Icons.logout,
                    size: 18, color: AppTheme.textPrimary),
                label: const Text(
                  'Keluar',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side:
                      const BorderSide(color: AppTheme.textPrimary, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS COMPONENT ---

  Widget _buildStatCard(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          if (index == items.length - 1) {
            return items[index];
          }
          return Column(
            children: [
              items[index],
              const Divider(
                  height: 1,
                  color: Color(0xFFF3F4F6),
                  indent: 16,
                  endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData leadingIcon,
    String title, {
    String? trailingText,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(leadingIcon, color: AppTheme.textPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary),
              ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary, size: 12),
            ]
          ],
        ),
      ),
    );
  }
}
