import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_config.dart';

abstract class FluffyThemes {
  static const double columnWidth = 380.0;

  static const double maxTimelineWidth = columnWidth * 2;

  static const double navRailWidth = 80.0;

  static bool isColumnModeByWidth(double width) =>
      width > columnWidth * 2 + navRailWidth;

  static bool isColumnMode(BuildContext context) =>
      isColumnModeByWidth(MediaQuery.of(context).size.width);

  static bool isThreeColumnMode(BuildContext context) =>
      MediaQuery.of(context).size.width > FluffyThemes.columnWidth * 3.5;

  static LinearGradient backgroundGradient(
    BuildContext context,
    int alpha,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topCenter,
      colors: [
        colorScheme.primaryContainer.withAlpha(alpha),
        colorScheme.secondaryContainer.withAlpha(alpha),
        colorScheme.tertiaryContainer.withAlpha(alpha),
        colorScheme.primaryContainer.withAlpha(alpha),
      ],
    );
  }

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;

  static ThemeData buildTheme(
    BuildContext context,
    Brightness brightness, [
    Color? seed,
  ]) {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF3EC2CF), // N MEXE
      onPrimary: Color(0xFF4F4F4F),
      primaryFixed: Color.fromARGB(0, 255, 255, 255), // N MEXE
      primaryContainer: Color(0xFFadadad), // N MEXE
      onPrimaryContainer: Color(0xFF212529), //N MEXE
      secondary: Color(0xFF8B89AD), // N MEXE
      onSecondary: Color(0xCCF7F7F7), // N MEXE
      secondaryContainer: Color(0xFF8B89AD),
      onSecondaryContainer: Color(0xFFADB5BD),
      tertiary: Color(0xFFF7F7F7), // N MEXE
      onTertiary: Color(0xFF4F4F4F),
      tertiaryContainer: Color(0xFF3D3D3D),
      onTertiaryContainer: Color(0xFF646464), // N MEXE
      surface: Color(0xFF4F4F4F), // N MEXE
      onSurface: Color(0xFF646464), // N MEXE
      surfaceContainerLow: Color(0xFF3EC2CF), // N MEXE
      surfaceContainer: Color(0xFFF7F7F7), // N MEXE
      surfaceContainerHighest: Color(0xFF8B89AD), // N MEXE
      surfaceContainerHigh: Color(0xFF4F4F4F), // N MEXE
      error: Color.fromARGB(255, 243, 117, 117), // N MEXE
      onError: Color.fromARGB(255, 243, 117, 117),
      errorContainer: Color.fromARGB(255, 243, 117, 117),
      onErrorContainer: Color(0xFF000000),
      surfaceTint: Color(0xFF3EC2CF),
      outline: Color(0xFF3EC2CF),
    );

    final isColumnMode = FluffyThemes.isColumnMode(context);
    return ThemeData(
      textTheme: Theme.of(context).textTheme.copyWith(
            bodyMedium: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.tertiary,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.tertiary,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.tertiary,
            ),
            titleLarge: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.tertiary,
            ),
            titleSmall: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.tertiary,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
      splashColor: colorScheme.primary.withValues(alpha: 0.1),
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      dividerColor: colorScheme.onSecondaryContainer,
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        iconColor: colorScheme.onSurface,
        textStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          iconColor: colorScheme.onPrimary,
          selectedBackgroundColor: colorScheme.primary,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.onSurface.withAlpha(128),
        selectionHandleColor: colorScheme.secondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface, width: 0.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface),
        ),
        labelStyle: TextStyle(
          fontFamily: 'GothamRndSSm',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSecondaryContainer,
        ),
        prefixIconColor: colorScheme.onSecondaryContainer,
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
        selectedColor: colorScheme.primary.withValues(alpha: 0.6),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        labelStyle: TextStyle(
          color: colorScheme.tertiary,
        ),
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: isColumnMode ? 72 : 56,
        shadowColor: null,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isColumnMode ? colorScheme.surface : null,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness.reversed,
          statusBarBrightness: brightness,
          systemNavigationBarIconBrightness: brightness.reversed,
          systemNavigationBarColor: colorScheme.surface,
        ),
        foregroundColor: colorScheme.tertiary,
        iconTheme: IconThemeData(
          color: colorScheme.tertiary, // escolha a cor que quiser
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            width: 1,
            color: colorScheme.surface,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.surface),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
        ),
      ),
      snackBarTheme: isColumnMode
          ? const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              width: FluffyThemes.columnWidth * 1.5,
            )
          : const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.surface,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.primary.withOpacity(0.6),
        iconColor: colorScheme.primary.withOpacity(0.6),
        selectedColor: colorScheme.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        titleTextStyle:
            TextStyle(fontFamily: 'GothamRndSSm', color: colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w400),
        contentTextStyle: TextStyle(
          color: colorScheme.onSecondaryContainer,
          decorationColor: colorScheme.onSurface,
        ),
      ),
    );
  }
}

extension on Brightness {
  Brightness get reversed =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}

extension BubbleColorTheme on ThemeData {
  Color get bubbleColor => brightness == Brightness.light
      ? colorScheme.secondary
      : colorScheme.secondary.withValues(alpha: 1);

  Color get onBubbleColor => colorScheme.onSecondary;

  Color get secondaryBubbleColor => brightness == Brightness.light
      ? colorScheme.tertiary
      : colorScheme.secondary.withValues(alpha: 0.5);
}
