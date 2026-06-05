import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'welcome_aboard_screen.dart';

class FlightUpdatesScreen extends StatelessWidget {
  const FlightUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 132),
          _buildImageSection(),
          const SizedBox(height: 32),
          Text(
            'Flight Updates',
            style: AppTheme.onboardingTitle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Text(
              'Stay updated with live flight information departure times, delays, gate changes, and more in one place.',
              textAlign: TextAlign.center,
              style: AppTheme.onboardingDescription,
            ),
          ),
          const Spacer(),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    const BorderRadius customRadius = BorderRadius.only(
      topLeft: Radius.circular(180),
      topRight: Radius.circular(250),
      bottomLeft: Radius.circular(250),
      bottomRight: Radius.circular(180),
    );

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 335,
            height: 427,
            decoration: const BoxDecoration(
              color: AppColors.onboardingCircleBg,
              borderRadius: customRadius,
            ),
            child: ClipRRect(
              borderRadius: customRadius,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: 47,
                    left: -12,
                    child: Image.asset(
                      'assets/images/onboarding_flight.png',
                      width: 343,
                      height: 370,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -68,
            left: 60,
            child: Image.asset(
              'assets/images/logo_travora.png',
              width: 218,
              height: 218,
              color: AppColors.primary,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WelcomeAboardScreen()),
              ),
              style: OutlinedButton.styleFrom(
                fixedSize: const Size.fromHeight(52),
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTheme.skipButtonText,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WelcomeAboardScreen()),
              ),
              child: Container(
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
                    'Next',
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
}
