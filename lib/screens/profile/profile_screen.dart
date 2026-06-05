import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/models/profile/profile_model.dart';
import 'package:graduation_project/services/profile_service/profile_service.dart';
import 'package:graduation_project/services/auth_service/login_service.dart'; // تأكدي من صحة المسار هنا
import 'sub_screens/account_info_screen.dart';
import 'sub_screens/change_password_screen.dart';
import 'sub_screens/payment/payment_screen.dart';
import 'sub_screens/settings_screen.dart';
import 'sub_screens/my_flights_screen.dart';
import '../my_orders/orders_screen.dart';
import '../auth/signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? passedName;

  const ProfileScreen({super.key, this.passedName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  ProfileModel? userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService().getProfile();
      setState(() {
        userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, 
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEAEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF3B3B),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Log Out?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Color(0xFF1D2733),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to Log\nout? This action cannot be\nundone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await LoginService().logout();

                      if (!mounted) return;

                      Navigator.pop(context);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Yes, Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF274C77)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No, Keep Sign In',
                      style: TextStyle(
                        color: Color(0xFF274C77),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF274C77)),
              title: const Text('Photo Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF274C77)),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      final imageFile = File(selectedImage.path);
      setState(() {
        _image = imageFile;
      });

      try {
        final photoUrl = await ProfileService().uploadPhoto(imageFile);
        setState(() {
          userProfile = ProfileModel(
            customerId: userProfile?.customerId ?? 0,
            firstName: userProfile?.firstName ?? '',
            lastName: userProfile?.lastName ?? '',
            email: userProfile?.email ?? '',
            profileImageUrl: photoUrl,
            accountStatus: userProfile?.accountStatus,
          );
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload photo")),
          );
        }
      }
    }
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
          'Profile',
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF274C77).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: _image != null
                                    ? Image.file(_image!, fit: BoxFit.cover)
                                    : userProfile?.profileImageUrl != null
                                        ? Image.network(
                                            userProfile!.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                Image.asset(
                                              'assets/images/profile_icon.png',
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : Center(
                                            child: Image.asset(
                                              'assets/images/profile_icon.png',
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: textColor.withOpacity(0.2),
                                          blurRadius: 4)
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF274C77),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProfile == null
                              ? "Traveler"
                              : (userProfile!.firstName.isEmpty &&
                                      userProfile!.lastName.isEmpty)
                                  ? "Traveler"
                                  : "${userProfile!.firstName} ${userProfile!.lastName}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF274C77),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 14),
                  _buildProfileItem(
                    'assets/images/personal_information_icon.png',
                    'Account Information',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountInfoScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    'assets/images/change_password_icon.png',
                    'Change Password',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    'assets/images/payment_icon.png',
                    'Payment Information',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    'assets/images/my_orders_icon.png',
                    'My Orders',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrdersScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    'assets/images/settings.png',
                    'Settings',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Travel History'),
                  const SizedBox(height: 14),
                  _buildProfileItem(
                    'assets/images/my_flights_icon.png',
                    'My Flights',
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyFlightsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Others'),
                  const SizedBox(height: 14),
                  _buildProfileItem(null, 'Log Out',
                      isLogout: true,
                      fallbackIcon: Icons.logout,
                      onTap: _showLogoutDialog,
                      textColor: textColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildProfileItem(String? imagePath, String title,
      {bool isLogout = false,
      IconData? fallbackIcon,
      VoidCallback? onTap,
      required Color textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isLogout
              ? const Color(0xFFFF0000).withOpacity(0.1)
              : const Color(0xFF96ACC1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: imagePath != null
            ? Image.asset(imagePath, width: 22, height: 22, fit: BoxFit.contain)
            : Icon(fallbackIcon,
                color: isLogout
                    ? const Color(0xFFFF0000)
                    : const Color(0xFF274C77),
                size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? const Color(0xFFFF0000) : textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
