import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

// ──────────────────────────────────────────────────────────────
//  Data model for a nav item
// ──────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _NavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'History',
  ),
  // Index 2 is the center FAB — handled separately
  _NavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Laporan',
  ),
  _NavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
  ),
];

// ──────────────────────────────────────────────────────────────
//  Main widget
// ──────────────────────────────────────────────────────────────
class BottomNavBar extends StatefulWidget {
  final void Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavBar({
    required this.onItemSelected,
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _fabCtrl;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _fabScale = _fabCtrl;
  }

  @override
  void didUpdateWidget(covariant BottomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      setState(() => selectedIndex = widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFabTap() async {
    await _fabCtrl.reverse();
    unawaited(_fabCtrl.forward());
    setState(() => selectedIndex = 2);
    widget.onItemSelected(2);
  }

  void _onItemTap(int rawIndex) {
    final navIndex = rawIndex >= 2 ? rawIndex + 1 : rawIndex;
    setState(() => selectedIndex = navIndex);
    widget.onItemSelected(navIndex);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1F2B) : Colors.white;
    final inactiveColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFFADB5BD);
    final activeColor = const Color(0xFF5B4FD4);
    const fabColor = Color(0xFF5B4FD4); // Deep purple FAB
    const fabGlow = Color(0x665B4FD4); // Glow halo

    return SizedBox(
      height: 70, // Sedikit dirampingkan agar proporsional
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Bar background with upward bump (cembung) ──
          Positioned.fill(
            child: CustomPaint(
              painter: _BumpBarPainter(color: bgColor, isDark: isDark),
            ),
          ),

          // ── Nav items left side ──
          Positioned(
            right: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width / 2 - 40,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(2, 3, activeColor, inactiveColor),
                _buildNavItem(3, 4, activeColor, inactiveColor),
              ],
            ),
          ),

          // ── Nav items right side ──
          Positioned(
            right: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width / 2 - 44,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(2, 3, activeColor, inactiveColor),
                _buildNavItem(3, 4, activeColor, inactiveColor),
              ],
            ),
          ),

          // ── Center FAB ──
          Positioned(
            top: -26, // Naik ke atas bump
            child: GestureDetector(
              onTap: _onFabTap,
              child: ScaleTransition(
                scale: _fabScale,
                child: Container(
                  width: 56, // Ukuran disesuaikan agar pas di dalam bump
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fabColor,
                    boxShadow: [
                      BoxShadow(
                        color: fabGlow,
                        blurRadius: 16,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: selectedIndex == 2 ? 0.125 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        selectedIndex == 2
                            ? Icons.close_rounded
                            : Icons.add_rounded,
                        color: Colors.white,
                        size: 32, // Ikon agak dibesarkan
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int rawIndex, // 0..3 for the 4 real items
    int navIndex, // actual page index (skips FAB slot)
    Color activeColor,
    Color inactiveColor,
  ) {
    final item = _navItems[rawIndex];
    final isActive = selectedIndex == navIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(rawIndex),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Top active indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 3,
              width: isActive ? 2 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(item.label),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Custom painter: Upward Bump Bar (Menggantikan Notched)
// ──────────────────────────────────────────────────────────────
class _BumpBarPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  const _BumpBarPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final path = Path()
      ..moveTo(0, 0)
      // Tarik garis lurus dari kiri hingga mendekati tengah
      ..lineTo(cx - 42, 0)
      // Buat lengkungan cembung ke atas (bump) untuk membungkus FAB
      ..cubicTo(cx - 20, 0, cx - 36, -34, cx, -34)
      ..cubicTo(cx + 36, -34, cx + 20, 0, cx + 42, 0)
      // Lanjutkan garis ke kanan
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Shadow yang halus untuk light mode
    if (!isDark) {
      canvas.drawShadow(path, Colors.black.withOpacity(0.06), 12, false);
    }

    // Fill background bar
    canvas.drawPath(path, Paint()..color = color);

    // Garis batas tipis di atas (opsional, menyesuaikan ketegasan warna)
    if (!isDark) {
      final p = Paint()
        ..color = const Color(0xFFF3F4F6)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_BumpBarPainter old) =>
      old.color != color || old.isDark != isDark;
}
