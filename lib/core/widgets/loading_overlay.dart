import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// A full-screen glassmorphism loading overlay.
/// Shows a blurred backdrop, animated spinner + pulsing icon, and contextual message.
///
/// Usage:
/// ```dart
/// Stack(children: [
///   // ... your content ...
///   AnimatedSwitcher(
///     duration: Duration(milliseconds: 300),
///     child: isLoading
///         ? LoadingOverlay(message: 'Please wait...')
///         : SizedBox.shrink(),
///   ),
/// ])
/// ```
class LoadingOverlay extends StatefulWidget {
  final String message;

  const LoadingOverlay({required this.message, super.key});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(
          color: context.colors.background.withOpacity(0.75),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: context.colors.outlineVariant.withOpacity(0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing Icon + Spinner Stack
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary.withOpacity(0.25),
                            ),
                          ),
                        ),
                        // Colored arc
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Pulsing center icon
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: context.colors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onBackground,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Contextual message
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Animated dots
                  const _AnimatedDots(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated Dots ──────────────────────────────────────────────────────────────
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = ((t - delay) % 1.0 + 1.0) % 1.0;
            final opacity = phase < 0.5
                ? (phase * 2).clamp(0.3, 1.0)
                : ((1.0 - phase) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
