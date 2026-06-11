import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDim;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;

  final Color secondary;
  final Color secondaryDim;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color secondaryContainer;
  final Color onSecondary;
  final Color onSecondaryContainer;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;

  final Color tertiary;
  final Color tertiaryDim;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color tertiaryContainer;
  final Color onTertiary;
  final Color onTertiaryContainer;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;

  final Color surface;
  final Color surfaceBright;
  final Color surfaceDim;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color surfaceTint;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;

  final Color background;
  final Color onBackground;

  final Color error;
  final Color errorDim;
  final Color errorContainer;
  final Color onError;
  final Color onErrorContainer;

  final Color outline;
  final Color outlineVariant;
  final Color inversePrimary;

  final Color lavender;
  final Color mint;
  final Color peach;
  final Color darkNav;
  final Color coral;
  final Color warmOrange;
  final Color warmYellow;

  const AppColors({
    required this.primary,
    required this.primaryDim,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.secondaryDim,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.secondaryContainer,
    required this.onSecondary,
    required this.onSecondaryContainer,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.tertiaryDim,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.tertiaryContainer,
    required this.onTertiary,
    required this.onTertiaryContainer,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.surface,
    required this.surfaceBright,
    required this.surfaceDim,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.surfaceTint,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.errorDim,
    required this.errorContainer,
    required this.onError,
    required this.onErrorContainer,
    required this.outline,
    required this.outlineVariant,
    required this.inversePrimary,
    required this.lavender,
    required this.mint,
    required this.peach,
    required this.darkNav,
    required this.coral,
    required this.warmOrange,
    required this.warmYellow,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? primaryDim,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onPrimaryContainer,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? secondary,
    Color? secondaryDim,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? secondaryContainer,
    Color? onSecondary,
    Color? onSecondaryContainer,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiary,
    Color? tertiaryDim,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? tertiaryContainer,
    Color? onTertiary,
    Color? onTertiaryContainer,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? surface,
    Color? surfaceBright,
    Color? surfaceDim,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? surfaceContainerLowest,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceVariant,
    Color? surfaceTint,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? errorDim,
    Color? errorContainer,
    Color? onError,
    Color? onErrorContainer,
    Color? outline,
    Color? outlineVariant,
    Color? inversePrimary,
    Color? lavender,
    Color? mint,
    Color? peach,
    Color? darkNav,
    Color? coral,
    Color? warmOrange,
    Color? warmYellow,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDim: primaryDim ?? this.primaryDim,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      secondary: secondary ?? this.secondary,
      secondaryDim: secondaryDim ?? this.secondaryDim,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondary: onSecondary ?? this.onSecondary,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiary: tertiary ?? this.tertiary,
      tertiaryDim: tertiaryDim ?? this.tertiaryDim,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiary: onTertiary ?? this.onTertiary,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      surface: surface ?? this.surface,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      errorDim: errorDim ?? this.errorDim,
      errorContainer: errorContainer ?? this.errorContainer,
      onError: onError ?? this.onError,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      lavender: lavender ?? this.lavender,
      mint: mint ?? this.mint,
      peach: peach ?? this.peach,
      darkNav: darkNav ?? this.darkNav,
      coral: coral ?? this.coral,
      warmOrange: warmOrange ?? this.warmOrange,
      warmYellow: warmYellow ?? this.warmYellow,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant: Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryDim: Color.lerp(secondaryDim, other.secondaryDim, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim: Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      onSecondaryFixed: Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      tertiaryDim: Color.lerp(tertiaryDim, other.tertiaryDim, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim: Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      onTertiaryContainer: Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant: Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface: Color.lerp(inverseOnSurface, other.inverseOnSurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorDim: Color.lerp(errorDim, other.errorDim, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      darkNav: Color.lerp(darkNav, other.darkNav, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      warmOrange: Color.lerp(warmOrange, other.warmOrange, t)!,
      warmYellow: Color.lerp(warmYellow, other.warmYellow, t)!,
    );
  }

  static const light = AppColors(
    primary: Color(0xFF2c5f87),
    primaryDim: Color(0xFF1d537a),
    primaryFixed: Color(0xFFa1d1fe),
    primaryFixedDim: Color(0xFF93c3ef),
    primaryContainer: Color(0xFFa1d1fe),
    onPrimary: Color(0xFFebf3ff),
    onPrimaryContainer: Color(0xFF0a476d),
    onPrimaryFixed: Color(0xFF003351),
    onPrimaryFixedVariant: Color(0xFF1a5177),
    secondary: Color(0xFF794f61),
    secondaryDim: Color(0xFF6c4455),
    secondaryFixed: Color(0xFFffc8dd),
    secondaryFixedDim: Color(0xFFf0bbcf),
    secondaryContainer: Color(0xFFffc8dd),
    onSecondary: Color(0xFFffeff3),
    onSecondaryContainer: Color(0xFF673f50),
    onSecondaryFixed: Color(0xFF512d3d),
    onSecondaryFixedVariant: Color(0xFF71485a),
    tertiary: Color(0xFF605e20),
    tertiaryDim: Color(0xFF545214),
    tertiaryFixed: Color(0xFFfefaab),
    tertiaryFixedDim: Color(0xFFefec9e),
    tertiaryContainer: Color(0xFFfefaab),
    onTertiary: Color(0xFFfaf6a8),
    onTertiaryContainer: Color(0xFF626021),
    onTertiaryFixed: Color(0xFF4f4d10),
    onTertiaryFixedVariant: Color(0xFF6c6a2b),
    surface: Color(0xFFf4f6ff),
    surfaceBright: Color(0xFFf4f6ff),
    surfaceDim: Color(0xFFbbd6ff),
    surfaceContainer: Color(0xFFdce9ff),
    surfaceContainerLow: Color(0xFFeaf1ff),
    surfaceContainerLowest: Color(0xFFffffff),
    surfaceContainerHigh: Color(0xFFd3e4ff),
    surfaceContainerHighest: Color(0xFFc9deff),
    surfaceVariant: Color(0xFFc9deff),
    surfaceTint: Color(0xFF2c5f87),
    onSurface: Color(0xFF13304f),
    onSurfaceVariant: Color(0xFF435d7f),
    inverseSurface: Color(0xFF000f21),
    inverseOnSurface: Color(0xFF859fc4),
    background: Color(0xFFf4f6ff),
    onBackground: Color(0xFF13304f),
    error: Color(0xFFb31b25),
    errorDim: Color(0xFF9f0519),
    errorContainer: Color(0xFFfb5151),
    onError: Color(0xFFffefee),
    onErrorContainer: Color(0xFF570008),
    outline: Color(0xFF5f789c),
    outlineVariant: Color(0xFF95afd5),
    inversePrimary: Color(0xFFa1d1fe),
    lavender: Color(0xFF6A89A7),
    mint: Color(0xFF88BDF2),
    peach: Color(0xFFBDDDFC),
    darkNav: Color(0xFF384959),
    coral: Color(0xFFE05C6B),
    warmOrange: Color(0xFFE07B6A),
    warmYellow: Color(0xFFD4A84B),
  );

  static const dark = AppColors(
    primary: Color(0xFF88BDF2),
    primaryDim: Color(0xFF6A89A7),
    primaryFixed: Color(0xFFBDDDFC),
    primaryFixedDim: Color(0xFF88BDF2),
    primaryContainer: Color(0xFF253F55),
    onPrimary: Color(0xFF0D1E2C),
    onPrimaryContainer: Color(0xFFD6EAFC),
    onPrimaryFixed: Color(0xFF0D1E2C),
    onPrimaryFixedVariant: Color(0xFF253F55),
    secondary: Color(0xFFBDDDFC),
    secondaryDim: Color(0xFF88BDF2),
    secondaryFixed: Color(0xFFEAF4FE),
    secondaryFixedDim: Color(0xFFBDDDFC),
    secondaryContainer: Color(0xFF384959),
    onSecondary: Color(0xFF061420),
    onSecondaryContainer: Color(0xFFBDDDFC),
    onSecondaryFixed: Color(0xFF061420),
    onSecondaryFixedVariant: Color(0xFF1D3448),
    tertiary: Color(0xFFD0E9FB),
    tertiaryDim: Color(0xFFBDDDFC),
    tertiaryFixed: Color(0xFFEAF4FE),
    tertiaryFixedDim: Color(0xFFD0E9FB),
    tertiaryContainer: Color(0xFF253F55),
    onTertiary: Color(0xFF0D1E2C),
    onTertiaryContainer: Color(0xFFEAF4FE),
    onTertiaryFixed: Color(0xFF0D1E2C),
    onTertiaryFixedVariant: Color(0xFF1D3448),
    surface: Color(0xFF1A2630),
    surfaceBright: Color(0xFF253F55),
    surfaceDim: Color(0xFF151D24),
    surfaceContainer: Color(0xFF1A2630),
    surfaceContainerLow: Color(0xFF151D24),
    surfaceContainerLowest: Color(0xFF0F151A),
    surfaceContainerHigh: Color(0xFF253F55),
    surfaceContainerHighest: Color(0xFF384959),
    surfaceVariant: Color(0xFF253F55),
    surfaceTint: Color(0xFF88BDF2),
    onSurface: Color(0xFFEAF4FE),
    onSurfaceVariant: Color(0xFFB0C8DC),
    inverseSurface: Color(0xFFEEF4FA),
    inverseOnSurface: Color(0xFF1A2630),
    background: Color(0xFF0F151A),
    onBackground: Color(0xFFEAF4FE),
    error: Color(0xFFFFB4AB),
    errorDim: Color(0xFFE05C6B),
    errorContainer: Color(0xFF93000A),
    onError: Color(0xFF690005),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: Color(0xFF546A7B),
    outlineVariant: Color(0xFF384959),
    inversePrimary: Color(0xFF6A89A7),
    lavender: Color(0xFF88BDF2),
    mint: Color(0xFFBDDDFC),
    peach: Color(0xFFEAF4FE),
    darkNav: Color(0xFF1A2630),
    coral: Color(0xFFFFB4AB),
    warmOrange: Color(0xFFFFB4A0),
    warmYellow: Color(0xFFFFE082),
  );
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
