import 'package:flutter/material.dart';
import 'package:graduation_project/models/profile/change_password_model.dart';
import 'package:graduation_project/services/profile_service/change_password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showErrorSnackBar("All fields are required!");
      return;
    }

    if (newPass.length < 8) {
      _showErrorSnackBar("New password must be at least 8 characters!");
      return;
    }

    if (newPass != confirm) {
      _showErrorSnackBar("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    await _changePasswordApi(current, newPass, confirm);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _changePasswordApi(
      String current, String newPass, String confirm) async {
    final requestData = ChangePasswordRequestModel(
      currentPassword: current,
      newPassword: newPass,
      confirmPassword: confirm,
    );

    try {
      await ChangePasswordService().changePassword(requestData);
      if (mounted) {
        _showSuccessSnackBar("Password changed successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1D2733);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF274C77), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Change Password',
            style: TextStyle(
                color: Color(0xFF274C77),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            PasswordInputField(
              label: "Current Password",
              hint: "Enter Current Password",
              controller: _currentPasswordController,
              textColor: textColor,
            ),
            const SizedBox(height: 25),
            PasswordInputField(
              label: "New Password",
              hint: "Enter new password",
              controller: _newPasswordController,
              textColor: textColor,
            ),
            const SizedBox(height: 25),
            PasswordInputField(
              label: "Confirm Password",
              hint: "Re-enter password",
              controller: _confirmPasswordController,
              textColor: textColor,
            ),
            const SizedBox(height: 50),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF274C77))
                : _buildSaveButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: _handleSave,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFFA3CEF1), Color(0xFF274C77)],
            stops: [0.0, 0.6],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF274C77).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
            child: Text("Save Changes",
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600))),
      ),
    );
  }
}

class PasswordInputField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color textColor;

  const PasswordInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.textColor,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textColor)),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            style: TextStyle(
                fontSize: 16, color: widget.textColor.withOpacity(0.9)),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: const Color(0xFF274C77).withOpacity(0.2),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(color: Color(0xFF274C77), width: 1)),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF274C77)),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
