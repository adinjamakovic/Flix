import 'package:flix_desktop/providers/auth_provider.dart';
import 'package:flix_desktop/providers/cast_provider.dart';
import 'package:flix_desktop/providers/clash_provider.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/providers/review_provider.dart';
import 'package:flix_desktop/providers/role_provider.dart';
import 'package:flix_desktop/providers/user_provider.dart';
import 'package:flix_desktop/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider() ),
            ChangeNotifierProvider(create: (_) => MovieProvider() ),
            ChangeNotifierProvider(create: (_) => CountryProvider() ),
            ChangeNotifierProvider(create: (_) => CastProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ReviewProvider()),
            ChangeNotifierProvider(create: (_) => ClashProvider()),
            ChangeNotifierProvider(create: (_) => RoleProvider())
          ],
        child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const ColorScheme flixColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Brand red: logo, primary buttons, active states.
    primary: Color(0xFFD9151C),
    onPrimary: Colors.white,

    // Deep red used behind the selected navigation item.
    primaryContainer: Color(0xFF8C0B10),
    onPrimaryContainer: Colors.white,

    // Sidebar / dark surfaces.
    secondary: Color(0xFF0A0A0C),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF16161A),
    onSecondaryContainer: Colors.white,

    // Muted grey used by table headers.
    tertiary: Color(0xFF6E6E76),
    onTertiary: Colors.white,

    error: Color(0xFFB3261E),
    onError: Colors.white,

    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF111114),
    surfaceContainerLowest: Colors.white,
    surfaceContainer: Color(0xFFF2F0F5),
    surfaceContainerHighest: Color(0xFFE3E3E8),
    onSurfaceVariant: Color(0xFF5A5A63),

    outline: Color(0xFFCFCFD6),
    outlineVariant: Color(0xFFE4E4EA),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flix',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: flixColorScheme,
        scaffoldBackgroundColor: const Color(0xFFE9E9EC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE9E9EC),
          foregroundColor: Color(0xFF111114),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF111114),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: flixColorScheme.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: flixColorScheme.surfaceContainer,
          hintStyle: TextStyle(color: flixColorScheme.onSurfaceVariant),
          labelStyle: TextStyle(color: flixColorScheme.onSurfaceVariant),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: flixColorScheme.primary, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: flixColorScheme.primary,
            foregroundColor: flixColorScheme.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: flixColorScheme.outlineVariant,
          space: 1,
          thickness: 1,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
