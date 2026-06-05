import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/signup/success_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF274C77),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontFamily: 'Inter'),
          bodyMedium: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontFamily: 'Inter'),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).scaffoldBackgroundColor),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Travora',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const SplashScreen(),
        routes: {
          '/accountCreated': (context) => const SuccessRegistrationScreen(),
        },
      ),
    );
  }
}
