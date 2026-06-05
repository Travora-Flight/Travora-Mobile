import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/flight_updates_screen.dart';
import '../onboarding/welcome_aboard_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showFullLogo = false;
  bool _startAnimation = false;
  bool _startMove = false;
  bool _showCard = false;
  bool _returnToWhite = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _startAnimation = true);
    });

    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showFullLogo = true);
    });

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _returnToWhite = true);
    });

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showCard = true;
          _startMove = true;
        });
      }
    });

    Timer(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final String? refreshToken = prefs.getString('refreshToken');

      if (!mounted) return;

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const HomeScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            tween: ColorTween(
              begin: AppColors.onboardingCircleBg,
              end: _returnToWhite
                  ? AppColors.background
                  : (_showFullLogo
                      ? AppColors.primary
                      : AppColors.onboardingCircleBg),
            ),
            builder: (context, bgColor, _) => Container(color: bgColor),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOutCubic,
              offset: _showCard ? Offset.zero : const Offset(0, 1),
              child: Container(
                height: screenHeight * 0.88,
                width: screenWidth,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: _buildFirstPageContent(),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
            top: _startMove ? 105 : (screenHeight / 2) - (217 / 2),
            left: (screenWidth / 2) - (217 / 2),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeInOutCubic,
              scale: _startMove ? 1.0 : (_startAnimation ? 1.0 : 0.85),
              child: _buildLogoWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget() {
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 1400),
      tween: ColorTween(
        begin: AppColors.background,
        end: _startMove ? AppColors.primary : AppColors.background,
      ),
      builder: (context, color, _) {
        return SizedBox(
          width: 217,
          height: 217,
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showFullLogo ? 0.0 : 1.0,
                child:
                    Image.asset('assets/images/logo_tra_ora.png', color: color),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showFullLogo ? 1.0 : 0.0,
                child:
                    Image.asset('assets/images/logo_travora.png', color: color),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFirstPageContent() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 336,
          height: 415,
          decoration: const BoxDecoration(
            color: AppColors.onboardingCircleBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(250),
              topRight: Radius.circular(250),
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 316,
              height: 368,
              child: Image.asset(
                'assets/images/onboarding_bags.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Bag Tracking',
          style: AppTheme.onboardingTitle,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Text(
            'Track your luggage in real time from drop-off to arrival. Travel with confidence, no more worries about lost bags.',
            textAlign: TextAlign.center,
            style: AppTheme.onboardingDescription,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const WelcomeAboardScreen()),
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: AppTheme.skipButtonText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const FlightUpdatesScreen()),
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd
                        ],
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
        ),
      ],
    );
  }
}
