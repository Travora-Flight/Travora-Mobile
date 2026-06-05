import 'package:flutter/material.dart';
import 'package:graduation_project/models/profile/account_model.dart';
import 'package:graduation_project/services/profile_service/account_service.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  late TextEditingController _passportController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _passportController = TextEditingController();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await AccountService().getAccount();
      setState(() {
        _firstNameController.text = account.firstName;
        _lastNameController.text = account.lastName;
        _phoneController.text = account.mobileNumber;
        _genderController.text = account.gender ?? "";
        _dobController.text = account.dateOfBirth ?? "";
        _passportController.text = account.passportNumber ?? "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _passportController.dispose();
    super.dispose();
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
        title: const Text(
          'Account Information',
          style: TextStyle(
            color: Color(0xFF274C77),
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTextField("First Name", _firstNameController,
                      "Enter your first name", textColor),
                  const SizedBox(height: 20),
                  _buildTextField("Last Name", _lastNameController,
                      "Enter your last name", textColor),
                  const SizedBox(height: 20),
                  _buildTextField("Mobile Num", _phoneController,
                      "e.g. +20123456789", textColor),
                  const SizedBox(height: 20),
                  _buildTextField(
                      "Gender", _genderController, "Male / Female", textColor,
                      readOnly: true),
                  const SizedBox(height: 20),
                  _buildTextField(
                      "Date Of Birth", _dobController, "DD/MM/YYYY", textColor,
                      readOnly: true),
                  const SizedBox(height: 20),
                  _buildTextField("Passport Number", _passportController,
                      "Enter passport number", textColor,
                      readOnly: true),
                  const SizedBox(height: 80),
                  _buildSaveButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String hint, Color textColor,
      {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
                color: readOnly
                    ? textColor.withOpacity(0.4)
                    : textColor.withOpacity(0.9),
                fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: const Color(0xFF274C77).withOpacity(0.20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFF274C77), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          final updatedUser = AccountModel(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            mobileNumber: _phoneController.text,
            gender: _genderController.text,
            dateOfBirth: _dobController.text,
            passportNumber: _passportController.text,
          );

          await AccountService().updateAccount(updatedUser);

          if (context.mounted) Navigator.pop(context);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saved successfully!")),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) Navigator.pop(context);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFFA3CEF1), Color(0xFF274C77)],
            stops: [0.0, 0.7],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            "Save Changes",
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
