import 'package:flix_mobile/providers/activity_provider.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/cast_member_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/providers/clash_provider.dart';
import 'package:flix_mobile/providers/country_provider.dart';
import 'package:flix_mobile/providers/genre_provider.dart';
import 'package:flix_mobile/providers/language_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/movie_recommender_provider.dart';
import 'package:flix_mobile/providers/movie_request_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/screens/register.dart';
import 'package:flix_mobile/theme/flix_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => CastMemberProvider()),
        ChangeNotifierProvider(create: (_) => ClashProvider()),
        ChangeNotifierProvider(create: (_) => ClashEntryProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => MovieRecommenderProvider()),
        ChangeNotifierProvider(create: (_) => MovieRequestProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
      child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flix',
      theme: flixTheme,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.62, 1.0],
                colors: [
                  Colors.transparent,
                  colors.surface.withValues(alpha: 0.45),
                  colors.surface.withValues(alpha: 0.88),
                  colors.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FLIX',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 52),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: colors.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
