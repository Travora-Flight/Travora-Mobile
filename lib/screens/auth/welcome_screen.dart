import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'signin_screen.dart';
import 'signup/signup_screen1.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Center(
                child: Image.asset(
                  'assets/images/logo_travora.png',
                  width: 310,
                  height: 260,
                  color: AppColors.primary,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              _buildAuthButtons(context),
              const SizedBox(height: 66),
              _buildSocialLoginSection(),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Text(
                  'By continuing, you agree to our Terms and Conditions and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF070707),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        // Log In Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          child: Container(
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Log In',
                style: AppTheme.buttonText,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen1()),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 46),
            side: const BorderSide(color: AppColors.primary, width: 2.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Sign Up',
            style: AppTheme.skipButtonText,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Or Login with',
                  style:
                      TextStyle(color: AppColors.primary, fontFamily: 'Inter')),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 66),
        _buildSocialButton(
            'Login with Google', 'assets/images/google_icon.png'),
        const SizedBox(height: 16),
        _buildSocialButton('Login with Apple', 'assets/images/apple_icon.png'),
      ],
    );
  }

  Widget _buildSocialButton(String label, String iconPath) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.primary, width: 2.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTheme.skipButtonText.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
