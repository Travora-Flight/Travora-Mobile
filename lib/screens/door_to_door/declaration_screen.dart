import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:graduation_project/services/customs_services/customs_service.dart';
import 'custom_declaration_screen.dart';
import 'policy_screen.dart';

class DeclarationScreen extends StatefulWidget {
  const DeclarationScreen({super.key});

  @override
  State<DeclarationScreen> createState() => _DeclarationScreenState();
}

class _DeclarationScreenState extends State<DeclarationScreen> {
  final CustomsService _customsService = CustomsService();
  bool _isLoading = false;

  Future<void> _handleChannelSelection(
      BuildContext context, String customsType) async {
    setState(() => _isLoading = true);

    try {
      final result =
          await _customsService.setCustomsType(customsType: customsType);

      if (!mounted) return;

      if (result.success) {
        if (customsType == 'GreenField') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PolicyScreen(serviceName: "Door to door service"),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomDeclarationScreen(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Declaration",
          style:
              TextStyle(color: Color(0xFF274C77), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Do you have any goods to declare?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 25),
                _buildChannelCard(
                  context,
                  title: "Green channel",
                  subtitle: "No goods exceeding allowances or prohibited items",
                  backgroundColor: const Color(0xFF00FF2F).withOpacity(0.25),
                  borderColor: const Color(0xFF00FF2F),
                  onTap: _isLoading
                      ? null
                      : () => _handleChannelSelection(context, 'GreenField'),
                ),
                const SizedBox(height: 20),
                _buildChannelCard(
                  context,
                  title: "Red channel",
                  subtitle: "Goods to declare that may incur duties or taxes",
                  backgroundColor: const Color(0xFFFF060A).withOpacity(0.25),
                  borderColor: const Color(0xFFFF060A),
                  onTap: _isLoading
                      ? null
                      : () => _handleChannelSelection(context, 'RedField'),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF274C77),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: borderColor,
        strokeWidth: 1,
        dashPattern: const [5, 5],
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF252525).withOpacity(0.78)),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
