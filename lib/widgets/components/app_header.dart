import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';

class AppHeader extends StatefulWidget {
  final bool showBackground;

  const AppHeader({super.key, this.showBackground = true});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String userName = 'Saver';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('user_name') ?? 'Saver';
    final firstName = fullName.split(' ').first;
    if (!mounted) return;
    setState(() {
      userName = firstName;
      userPhotoUrl = prefs.getString('user_photo');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left: Avatar + Greeting ──────────────────────────
          Row(
            children: [
              // Profile Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primaryFixed,          // #BDDDFC tint
                  border: Border.all(color: context.colors.secondary.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: userPhotoUrl != null
                      ? Image.network(
                          userPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.person, color: context.colors.primary),
                        )
                      : Image.network(
                          'https://ui-avatars.com/api/?name=$userName&background=BDDDFC&color=384959',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, $userName 👋',
                    style: GoogleFonts.nunito(
                      color: context.colors.onSurface,         // #1A2630
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 12,
                        color: context.colors.primary,         // #6A89A7
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total Balance',
                        style: GoogleFonts.nunito(
                          color: context.colors.onSurfaceVariant, // #546A7B
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Right: Notification Bell ─────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: context.colors.darkNav,             // #384959
                    size: 22,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF88BDF2),           // #88BDF2 sky-blue dot
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
