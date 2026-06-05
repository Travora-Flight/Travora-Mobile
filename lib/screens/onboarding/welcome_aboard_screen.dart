import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/welcome_screen.dart';

class WelcomeAboardScreen extends StatelessWidget {
  const WelcomeAboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 0),
          _buildImageSection('assets/images/onboarding_welcome.png'),
          const SizedBox(height: 108),
          Text(
            'Welcome Aboard',
            style: AppTheme.onboardingTitle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Text(
              'Discover a smarter way to track your bags and manage every part of your journey.',
              textAlign: TextAlign.center,
              style: AppTheme.onboardingDescription,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Get Started',
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imagePath) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 335,
          height: 484,
          decoration: const BoxDecoration(
            color: AppColors.onboardingCircleBg,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(250),
              bottomRight: Radius.circular(180),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 65,
              right: 6,
              bottom: 33,
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          top: 358,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/logo_travora.png',
            width: 600,
            height: 260,
            color: AppColors.primary,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
