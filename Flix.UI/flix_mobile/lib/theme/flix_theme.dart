import 'package:flutter/material.dart';

const ColorScheme flixColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFFD9151C),
  onPrimary: Colors.white,

  primaryContainer: Color(0xFF8C0B10),
  onPrimaryContainer: Colors.white,

  secondary: Color(0xFF1B2231),
  onSecondary: Color(0xFFE9ECF3),
  secondaryContainer: Color(0xFF232B3C),
  onSecondaryContainer: Color(0xFFE9ECF3),

  tertiary: Color(0xFF8A93A6),
  onTertiary: Color(0xFF0A0D17),

  error: Color(0xFFFF5A5F),
  onError: Colors.white,

  surface: Color(0xFF0A0D17),
  onSurface: Color(0xFFF2F4F8),
  surfaceContainerLowest: Color(0xFF05070E), 
  surfaceContainerLow: Color(0xFF0F131F),
  surfaceContainer: Color(0xFF161C2A), 
  surfaceContainerHigh: Color(0xFF1D2432),
  surfaceContainerHighest: Color(0xFF262E3E),
  onSurfaceVariant: Color(0xFF8A93A6),

  outline: Color(0xFF2A3242),
  outlineVariant: Color(0xFF1A2030),

  inverseSurface: Color(0xFFE9ECF3),
  onInverseSurface: Color(0xFF0A0D17),
  scrim: Color(0xCC000000),
  shadow: Colors.black,
);

/// Single source of truth for the mobile app's look. Read colors through
/// `Theme.of(context).colorScheme`, never as literals.
final ThemeData flixTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: flixColorScheme,
  scaffoldBackgroundColor: flixColorScheme.surface,

  appBarTheme: AppBarTheme(
    backgroundColor: flixColorScheme.surfaceContainerLowest,
    foregroundColor: flixColorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    // The "FLIX" wordmark.
    titleTextStyle: TextStyle(
      color: flixColorScheme.primary,
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    ),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: flixColorScheme.onSurface,
    unselectedLabelColor: flixColorScheme.onSurface,
    labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    unselectedLabelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    indicatorColor: flixColorScheme.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: flixColorScheme.surfaceContainerLowest,
    indicatorColor: flixColorScheme.primaryContainer,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
    height: 64,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: 26,
        color: states.contains(WidgetState.selected)
            ? flixColorScheme.onPrimaryContainer
            : flixColorScheme.onSurface,
      ),
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: flixColorScheme.surfaceContainerLowest,
    selectedItemColor: flixColorScheme.primary,
    unselectedItemColor: flixColorScheme.onSurface,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: flixColorScheme.surfaceContainer,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: flixColorScheme.surfaceContainer,
    hintStyle: TextStyle(color: flixColorScheme.onSurfaceVariant),
    labelStyle: TextStyle(color: flixColorScheme.onSurfaceVariant),
    prefixIconColor: flixColorScheme.onSurfaceVariant,
    suffixIconColor: flixColorScheme.onSurfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: flixColorScheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: flixColorScheme.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: flixColorScheme.error, width: 1.5),
    ),
  ),

  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor:
          WidgetStatePropertyAll(flixColorScheme.surfaceContainerHigh),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: flixColorScheme.primary,
      foregroundColor: flixColorScheme.onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: flixColorScheme.primary),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: flixColorScheme.onSurfaceVariant,
      backgroundColor: flixColorScheme.surfaceContainer,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),

  iconTheme: IconThemeData(color: flixColorScheme.onSurface),

  chipTheme: ChipThemeData(
    backgroundColor: flixColorScheme.surfaceContainer,
    selectedColor: flixColorScheme.primaryContainer,
    labelStyle: TextStyle(color: flixColorScheme.onSurfaceVariant),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),

  listTileTheme: ListTileThemeData(
    textColor: flixColorScheme.onSurface,
    iconColor: flixColorScheme.onSurfaceVariant,
  ),

  dividerTheme: DividerThemeData(
    color: flixColorScheme.outlineVariant,
    space: 1,
    thickness: 1,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: flixColorScheme.surfaceContainerHigh,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: flixColorScheme.surfaceContainerHighest,
    contentTextStyle: TextStyle(color: flixColorScheme.onSurface),
    behavior: SnackBarBehavior.floating,
  ),

  progressIndicatorTheme:
      ProgressIndicatorThemeData(color: flixColorScheme.primary),

  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFFF2F4F8),
    ),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFF2F4F8)),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF8A93A6)),
  ),
);
