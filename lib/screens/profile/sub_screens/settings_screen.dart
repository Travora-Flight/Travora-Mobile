import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/models/profile/settings_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/profile_service/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;
  bool _isLoading = true;

  final SettingsService _settingsService = SettingsService(ApiService());

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final settings = await _settingsService.getSettings(token);

      setState(() {
        isNotificationsEnabled = settings.notificationsEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final success = await _settingsService.updateSettings(
        token,
        SettingsModel(
          notificationsEnabled: isNotificationsEnabled,
          language: 'en',
        ),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF274C77);
    bool isDark = AdaptiveTheme.of(context).mode.isDark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Preferences"),
            _buildSettingItem(
              Icons.notifications_none_outlined,
              "Notifications",
              trailing: _buildSwitch(isNotificationsEnabled, (val) {
                setState(() => isNotificationsEnabled = val);
                _updateSettings(); 
              }),
            ),
            _buildSettingItem(
              Icons.dark_mode_outlined,
              "Dark Mode",
              trailing: _buildSwitch(isDark, (val) {
                if (val) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              }),
            ),
            _buildSettingItem(
              Icons.language_outlined,
              "Language",
              trailingText: "English",
            ),
            const SizedBox(height: 15),
            _buildSectionTitle("Security"),
            _buildSettingItem(Icons.lock_outline, "Privacy Policy"),
            _buildSettingItem(Icons.security_outlined, "Security Settings"),
            const SizedBox(height: 15),
            _buildSectionTitle("Support"),
            _buildSettingItem(Icons.help_outline, "Help Center"),
            _buildSettingItem(Icons.mail_outline, "Contact Us"),
            _buildSettingItem(Icons.description_outlined, "Terms & Conditions"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title,
      {Widget? trailing, String? trailingText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF96ACC1).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.4),
            ),
            child: Icon(icon,
                color: Theme.of(context).scaffoldBackgroundColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(
                  color: Color(0xFF9EA3AE), fontSize: 16, fontFamily: 'Inter'),
            ),
          if (trailing != null) trailing,
          if (trailing == null && trailingText == null)
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF9EA3AE), size: 14),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).scaffoldBackgroundColor,
        activeTrackColor: const Color(0xFF274C77),
        inactiveThumbColor: const Color(0xFFD1D5DB),
        inactiveTrackColor: const Color(0xFFF3F4F6),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return const Color(0xFFD1D5DB);
        }),
      ),
    );
  }
}
