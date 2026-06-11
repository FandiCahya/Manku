import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class AppHeader extends StatefulWidget {
  final bool showBackground;
  const AppHeader({super.key, this.showBackground = true});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String userName = 'Friend';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('user_name') ?? 'Friend';
    final firstName = fullName.split(' ').first;
    if (mounted) {
      setState(() {
        userName = firstName;
        userPhotoUrl = prefs.getString('user_photo');
      });
    }
  }

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 11) return '☀️';
    if (h < 15) return '🌤️';
    if (h < 18) return '🌇';
    return '🌙';
  }

  String _greetingText() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Good Morning';
    if (h < 15) return 'Good Afternoon';
    if (h < 18) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.lavender.withOpacity(0.25),
              border: Border.all(color: context.colors.lavender, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: context.colors.lavender.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: userPhotoUrl != null
                  ? Image.network(
                      userPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          const SizedBox(width: 14),

          // ── Greeting text ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greetingText()}, $userName ${_greetingEmoji()}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: context.colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Let's check your finances!",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ── Notification bell ──────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.warmYellow.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: context.colors.warmOrange,
              iconSize: 22,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return ColoredBox(
      color: context.colors.lavender.withOpacity(0.2),
      child: Icon(Icons.person_rounded, color: context.colors.lavender, size: 28),
    );
  }
}
