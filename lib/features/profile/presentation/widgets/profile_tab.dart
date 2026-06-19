import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    required this.onLogout,
    super.key,
  });

  final VoidCallback onLogout;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final languageProvider = context.watch<LanguageProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('settings'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SettingItemTile(
            title: l10n.translate('account_settings'),
            icon: Icons.security,
            color: context.colors.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('account_settings'))),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingToggleTile(
            title: 'Dark Mode',
            icon: Icons.dark_mode,
            color: const Color(0xFF42A5F5),
            value: isDarkMode,
            onChanged: (val) {
              context.read<ThemeCubit>().updateTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const SizedBox(height: 10),
          SettingItemTile(
            title: l10n.translate('language'),
            icon: Icons.language,
            color: Colors.purple,
            trailing: Text(
              languageProvider.isEnglish ? 'English' : 'Bahasa',
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 10),
          SettingItemTile(
            title: l10n.translate('about_app'),
            icon: Icons.info_outline,
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ManKu v1.0.0')),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(
                l10n.translate('logout'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = context.read<LanguageProvider>();
    
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(l10n.translate('english')),
              trailing: languageProvider.isEnglish 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                languageProvider.setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: Text(l10n.translate('indonesian')),
              trailing: languageProvider.isIndonesian 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                languageProvider.setLanguage('id');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.translate('logout_confirmation')),
        content: Text(l10n.translate('logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.translate('logout')),
          ),
        ],
      ),
    );
  }
}

class SettingItemTile extends StatelessWidget {
  const SettingItemTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: context.colors.outlineVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

class SettingToggleTile extends StatelessWidget {
  const SettingToggleTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: Switch(
          value: value,
          activeThumbColor: context.colors.primary,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
