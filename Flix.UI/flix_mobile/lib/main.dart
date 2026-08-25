import 'package:flix_mobile/providers/activity_provider.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/cast_member_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/providers/clash_provider.dart';
import 'package:flix_mobile/providers/country_provider.dart';
import 'package:flix_mobile/providers/diary_provider.dart';
import 'package:flix_mobile/providers/genre_provider.dart';
import 'package:flix_mobile/providers/language_provider.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/providers/movie_issue_report_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/movie_recommender_provider.dart';
import 'package:flix_mobile/providers/movie_request_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/providers/studio_provider.dart';
import 'package:flix_mobile/providers/user_network_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/providers/user_report_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/screens/register.dart';
import 'package:flix_mobile/theme/flix_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  AuthProvider.onSessionExpired = _returnToLogin;

  runApp(
      MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => CastMemberProvider()),
        ChangeNotifierProvider(create: (_) => StudioProvider()),
        ChangeNotifierProvider(create: (_) => ClashProvider()),
        ChangeNotifierProvider(create: (_) => ClashEntryProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => MovieRecommenderProvider()),
        ChangeNotifierProvider(create: (_) => MovieRequestProvider()),
        ChangeNotifierProvider(create: (_) => MovieIssueReportProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserNetworkProvider()),
        ChangeNotifierProvider(create: (_) => UserReportProvider()),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ],
      child: const MyApp(),));
}

// The session can run out under any tab, so the redirect goes through the root
// navigator — a push into a tab's navigator would leave the nav bar up.
void _returnToLogin() {
  rootNavigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const Login()),
    (route) => false,
  );

  _messengerKey.currentState?.showSnackBar(
    const SnackBar(
      content: Text("Your session has expired. Please sign in again."),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flix',
      theme: flixTheme,
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: _messengerKey,
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
