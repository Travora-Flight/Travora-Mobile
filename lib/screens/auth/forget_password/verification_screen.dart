import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'set_new_password_screen.dart';
import 'package:graduation_project/models/auth/verify_email_model.dart';
import 'package:graduation_project/services/auth_service/verify_otp_service.dart';
import 'package:graduation_project/services/auth_service/verify_email_service.dart';
import 'package:graduation_project/services/auth_service/forget_password_service.dart'; // إضافة السيرفس هنا

class VerificationScreen extends StatefulWidget {
  final String email;
  final bool isRegister;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.isRegister,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  bool _isLoading = false;

  final VerifyOtpService _verifyOtpService = VerifyOtpService();
  final VerifyEmailService _verifyEmailService = VerifyEmailService();
  final ForgetPasswordService _forgetPasswordService =
      ForgetPasswordService();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleVerification() async {
    String otpCode = _controllers.map((e) => e.text).join();

    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isRegister) {
        await _verifyEmailService.verifyEmail(
          VerifyEmailRequestModel(
            email: widget.email,
            otp: otpCode,
          ),
        );

        if (mounted) {
          Navigator.pushNamed(context, '/accountCreated');
        }
      } else {
        final response = await _verifyOtpService.verifyOtp(
          email: widget.email,
          otp: otpCode,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetNewPasswordScreen(
                email: widget.email,
                resetToken: response.resetToken!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResendCode() async {
    try {
      if (widget.isRegister) {
        await _verifyEmailService.resendVerificationEmail(widget.email);
      } else {
        await _forgetPasswordService.forgotPassword(widget.email);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code resent successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF274C77), size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF274C77)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to ${widget.email}',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 52),
                Center(
                    child: Image.asset('assets/images/Authentication.png',
                        height: 250, fit: BoxFit.contain)),
                const SizedBox(height: 110),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      6, (index) => _buildCodeBox(context, index)),
                ),
                const SizedBox(height: 40),
                _buildContinueButton(context),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive code? ",
                          style: TextStyle(color: Colors.black, fontSize: 14)),
                      GestureDetector(
                        onTap: _handleResendCode,
                        child: const Text("Send Again",
                            style: TextStyle(
                                color: Color(0xFF274C77),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(BuildContext context, int index) {
    return SizedBox(
      width: 46,
      height: 46,
      child: TextFormField(
        controller: _controllers[index],
        onChanged: (value) {
          if (value.length == 1 && index < 5)
            FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0)
            FocusScope.of(context).previousFocus();
        },
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF274C77), width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF274C77), width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF274C77), width: 2)),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text('Continue',
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
      ),
    );
  }
}
