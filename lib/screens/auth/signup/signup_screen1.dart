import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/AuthLayout.dart';
import '../../../models/auth/signup_model.dart';
import '../../../models/auth/signup_response_model.dart';
import '../../../services/auth_service/signup_service.dart';
import '../signin_screen.dart';
import 'signup_screen2.dart';

class SignUpScreen1 extends StatefulWidget {
  const SignUpScreen1({super.key});

  @override
  State<SignUpScreen1> createState() => _SignUpScreen1State();
}

class _SignUpScreen1State extends State<SignUpScreen1> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleStep1() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final signUpData = SignUpRequestModel(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        );

        final SignUpResponseModel response =
            await _authService.registerStep1(signUpData);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpScreen2(
              firstName: signUpData.firstName,
              lastName: signUpData.lastName,
              email: signUpData.email,
              mobile: signUpData.mobile,
              password: signUpData.password,
              confirmPassword: signUpData.confirmPassword,
              sessionId: response.sessionId,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: '',
      subtitle: null,
      showBackButton: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_travora.png',
                          height: 290,
                          width: 510,
                          fit: BoxFit.contain,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('First Name'),
                          _buildTextField(
                            controller: firstNameController,
                            hintText: 'Enter first name',
                            action: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'First name is required';
                              if (value.length < 2)
                                return 'Minimum 2 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Last Name'),
                          _buildTextField(
                            controller: lastNameController,
                            hintText: 'Enter last name',
                            action: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Last name is required';
                              if (value.length < 2)
                                return 'Minimum 2 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Email Address'),
                          _buildTextField(
                            controller: emailController,
                            hintText: 'Enter email address',
                            keyboardType: TextInputType.emailAddress,
                            action: TextInputAction.next,
                            autofill: AutofillHints.email,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Email is required';
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value))
                                return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Phone Number'),
                          _buildTextField(
                            controller: mobileController,
                            hintText: '01xxxxxxxxx',
                            keyboardType: TextInputType.phone,
                            action: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Phone number is required';
                              if (!RegExp(r'^01\d{9}$').hasMatch(value))
                                return 'Enter a valid 11-digit Egyptian number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Password'),
                          _buildPasswordField(
                            controller: passwordController,
                            hintText: 'Enter password',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            action: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Password is required';
                              if (value.length < 8)
                                return 'Password must be at least 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Confirm Password'),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            hintText: 'Re-enter password',
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            action: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please confirm your password';
                              if (value != passwordController.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          _buildNextButton(context),
                          const SizedBox(height: 40),
                          _buildLoginPrompt(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text,
          style: AppTheme.fieldLabel
              .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextInputType? keyboardType,
    required TextEditingController controller,
    required TextInputAction action,
    String? autofill,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      autofillHints: autofill != null ? [autofill] : null,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.hintStyle.copyWith(fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF274C77).withOpacity(0.20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction action,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.hintStyle.copyWith(fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF274C77).withOpacity(0.20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleStep1,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text('Next', style: AppTheme.buttonText),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignInScreen())),
        child: RichText(
          text: TextSpan(
            text: 'Already Have an Account? ',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold),
            children: const [
              TextSpan(
                  text: 'Sign In',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ),
    );
  }
}
