import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'profile_info_page.dart';
import 'change_password_page.dart';
import 'two_factor_auth_page.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildMenuItem(
            context: context,
            title: 'Informasi Profil',
            subtitle: 'Ubah nama dan email Anda',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileInfoPage()));
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Ubah Kata Sandi',
            subtitle: 'Perbarui kata sandi akun',
            icon: Icons.lock_outline,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Autentikasi 2 Langkah (2FA)',
            subtitle: 'Tingkatkan keamanan akun',
            icon: Icons.security,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TwoFactorAuthPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.outlineVariant),
      onTap: onTap,
    );
  }
}
