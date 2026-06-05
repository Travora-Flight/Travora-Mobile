import 'package:flutter/material.dart';

class AppColors {
  static const Color splashLight = Color(0xFFA3CEF1);
  static const Color splashMedium = Color(0xFF7BA5C4);
  static const Color splashDark = Color(0xFF274C77);

  static const Color primary = Color(0xFF274C77);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);

  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color hintText = Color(0xFF7B7B7B);
  static const Color fieldLabel = Color(0xFF000000);
  static const Color borderLight = Color(0xFFE8ECF4);

  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);

  static const Color onboardingTitle = Color(0xFF274C77);
  static const Color onboardingDescription = Color(0xFF777777);
  static const Color skipButtonBorder = Color(0xFF274C77);

  static const Color gradientStart = Color(0xFF274C77);

  static const Color gradientEnd = Color(0xFFA3CEF1);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      gradientStart,
      gradientEnd,
    ],
  );

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFF274C77).withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static const Color onboardingCircleBg = Color(0xFFA3CEF1);
  static const Color black = Color(0xFF000000);
  static const Color fieldBackground = Color(0xFFF1F4F8);
  static const Color chipGold = Color(0xFFC0A060);
}
