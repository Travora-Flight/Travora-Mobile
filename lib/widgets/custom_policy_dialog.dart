import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/cancel_order_dialog.dart';

class PolicyDialogContent extends StatefulWidget {
  final String serviceName;
  final VoidCallback onAccept;

  const PolicyDialogContent({
    super.key,
    required this.serviceName,
    required this.onAccept,
  });

  @override
  State<PolicyDialogContent> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyDialogContent> {
  bool _isAccepted = false;
  static const Color darkBlue = Color(0xFF274C77);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkBlue.withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 25,
                      left: 5,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: darkBlue, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -18),
                            child: Image.asset(
                              'assets/images/logo_travora.png',
                              height: 150,
                              color: darkBlue,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -60),
                            child: Text(
                              "${widget.serviceName} service",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -35),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Please read the terms and conditions carefully before using the service",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13, height: 1.2),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildSectionTitle("Terms and Conditions"),
                        _buildSubSectionTitle("1. Service Scope"),
                        _buildContentText(
                            "The Luggage Transfer & Tracking Service provides comprehensive solutions for transporting your belongings to and from airports, hotels, and various locations. We guarantee the safety of your luggage and timely delivery with real-time tracking capabilities."),
                        const SizedBox(height: 30),
                        _buildSubSectionTitle("2. Customer Responsibility"),
                        _buildContentText(
                            "• Ensure luggage contents are free of prohibited or hazardous materials\n• Provide accurate pickup and delivery location information\n• Be present at the scheduled time for luggage pickup or delivery\n• Keep the tracking number for your shipment"),
                        const SizedBox(height: 30),
                        _buildSubSectionTitle("3. Prohibited Items"),
                        _buildContentText(
                            "Transport of hazardous materials, flammable items, perishable food, animals, plants, and large amounts of cash is strictly prohibited."),
                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _isAccepted,
                                onChanged: (val) {
                                  setState(() {
                                    _isAccepted = val!;
                                  });
                                },
                                activeColor: darkBlue,
                                side: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "I agree to all the terms and conditions mentioned above and acknowledge that I have read and understood them completely",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showCancelOrderDialog(context), // بدون orderId
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: darkBlue, width: 1.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: const Text("Cancel Order",
                              style: TextStyle(
                                  color: darkBlue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isAccepted
                                  ? [darkBlue, const Color(0xFFA3CEF1)]
                                  : [
                                      Colors.grey.shade400,
                                      Colors.grey.shade300
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _isAccepted ? widget.onAccept : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text("Accept",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text("Last updated: January 2026",
                    style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black)),
      );

  Widget _buildSubSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87)),
      );

  Widget _buildContentText(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 13.5, color: Colors.black.withOpacity(0.7), height: 1.5),
      );
}
