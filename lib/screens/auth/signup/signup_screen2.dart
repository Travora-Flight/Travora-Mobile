import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/AuthLayout.dart';
import '../../../models/auth/signup_model.dart';
import '../../../services/auth_service/signup_service.dart';
import '../signin_screen.dart';
import '../forget_password/verification_screen.dart';
import 'passport_scanner_screen.dart';

class SignUpScreen2 extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? password;
  final String? confirmPassword;
  final String? sessionId;

  const SignUpScreen2({
    super.key,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.confirmPassword,
    this.sessionId,
  });

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _showImageError = false;

  final TextEditingController _passportNumController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  File? _passportImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _passportNumController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scan Passport (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PassportScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _passportImage = result;
        _showImageError = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _passportImage = File(image.path);
        _showImageError = false;
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveImageToGallery() async {
    if (_passportImage == null) return;

    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        granted = true;
      } else {
        final status = await Permission.storage.request();
        granted = status.isGranted;
      }
    } else {
      granted = true;
    }

    if (granted) {
      final result = await ImageGallerySaver.saveFile(_passportImage!.path);
      if (!mounted) return;
      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save image'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFullImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.file(
                  _passportImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _saveImageToGallery();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Save to Gallery',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFinalSignUp() async {
    FocusScope.of(context).unfocus();
    bool isFormValid = _formKey.currentState!.validate();
    setState(() => _showImageError = _passportImage == null);

    if (isFormValid && _passportImage != null) {
      setState(() => _isLoading = true);
      try {
        SignUpRequestModel finalData = SignUpRequestModel(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          mobile: widget.mobile,
          password: widget.password,
          confirmPassword: widget.confirmPassword,
          sessionId: widget.sessionId,
          passportNumber: _passportNumController.text.trim(),
          expiryDate: _expiryController.text,
        );

        await _authService.registerStep2(
          signUpData: finalData,
          passportImage: _passportImage!,
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: widget.email ?? "",
              isRegister: true,
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
                          width: 500,
                          fit: BoxFit.contain,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 110, left: 4, right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Passport Number'),
                          _buildTextField(
                            controller: _passportNumController,
                            hintText: 'Enter passport number',
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Passport number is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Expiry Date'),
                          _buildTextField(
                            hintText: 'YYYY-MM-DD',
                            controller: _expiryController,
                            readOnly: true,
                            onTap: _selectExpiryDate,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Expiry date is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          _buildUploadSection(),
                          const SizedBox(height: 32),
                          _buildSignUpButton(context),
                          const SizedBox(height: 24),
                          _buildLoginPrompt(context),
                          const SizedBox(height: 40),
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
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(text,
          style: AppTheme.fieldLabel
              .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    TextEditingController? controller,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.hintStyle.copyWith(fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF274C77).withOpacity(0.20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Passport Photo'),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _passportImage == null ? _showPickerOptions : _showFullImage,
          child: DottedBorder(
            color: (_showImageError && _passportImage == null)
                ? Colors.red
                : AppColors.primary.withOpacity(0.5),
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            child: Container(
              width: double.infinity,
              height: _passportImage == null ? 100 : 200,
              decoration: BoxDecoration(
                color: const Color(0xFF274C77).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _passportImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined,
                            color: AppColors.primary, size: 30),
                        const SizedBox(height: 6),
                        Text('Upload Passport Photo',
                            style: AppTheme.hintStyle.copyWith(
                                color: AppColors.primary.withOpacity(0.8),
                                fontSize: 13)),
                      ],
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _passportImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('Tap to view',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _showPickerOptions,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text('Change',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_showImageError && _passportImage == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text("Please upload your passport photo",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleFinalSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text('Sign Up',
                style: AppTheme.buttonText.copyWith(fontSize: 16)),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignInScreen())),
        child: RichText(
          text: const TextSpan(
            text: 'Already Have an Account? ',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            children: [
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
