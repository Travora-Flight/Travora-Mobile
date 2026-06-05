import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/AuthLayout.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/login_response_model.dart';
import '../../services/auth_service/login_service.dart';
import 'signup/signup_screen1.dart';
import 'forget_password/forget_password_screen.dart';
import 'forget_password/verification_screen.dart';
import '../home/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _handleBackAction() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackAction();
      },
      child: AuthLayout(
        title: '',
        subtitle: null,
        showBackButton: true,
        onBackButtonTap: _handleBackAction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -70),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo_travora.png',
                                  height: 260,
                                  width: 400,
                                  fit: BoxFit.contain,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -86),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Email Address',
                                      style: AppTheme.fieldLabel),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    context,
                                    hintText: 'Enter email address',
                                    controller: emailController,
                                  ),
                                  const SizedBox(height: 20),
                                  Text('Password', style: AppTheme.fieldLabel),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    context,
                                    hintText: 'Enter password',
                                    isPassword: _obscurePassword,
                                    controller: passwordController,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgetPasswordScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Forget Password?',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  _buildSignInButton(context),
                                  const SizedBox(height: 50),
                                  _buildSocialSection(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: _buildSignUpPrompt(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill all fields"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          LoginRequestModel loginData =
              LoginRequestModel(email: email, password: password);

          await LoginService().login(loginData);

          if (context.mounted) Navigator.pop(context);

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, a1, a2) => const HomeScreen(),
                transitionDuration: Duration.zero,
              ),
              (route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) Navigator.pop(context);

          final errorMsg = e.toString().replaceAll("Exception: ", "");

          if (context.mounted) {
            if (errorMsg.toLowerCase().contains("verify your email")) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerificationScreen(
                    email: emailController.text.trim(),
                    isRegister: true,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('Sign In', style: AppTheme.buttonText),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen1()),
          );
        },
        child: RichText(
          text: TextSpan(
            text: "Don't Have an Account? ",
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
            children: const [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context,
      {required String hintText,
      bool isPassword = false,
      Widget? suffixIcon,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.hintStyle,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF274C77).withOpacity(0.20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
                child: Divider(color: AppColors.primary, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or Sign up with',
                style: AppTheme.hintStyle
                    .copyWith(color: AppColors.primary, fontSize: 16),
              ),
            ),
            const Expanded(
                child: Divider(color: AppColors.primary, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon('assets/images/google_icon.png'),
            const SizedBox(width: 25),
            _buildSocialIcon('assets/images/apple_icon.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String path) {
    return Container(
      width: 95,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(path, width: 24, height: 24),
      ),
    );
  }
}
