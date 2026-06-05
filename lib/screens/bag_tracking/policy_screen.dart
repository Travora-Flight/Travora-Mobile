import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/custom_policy_dialog.dart';
import 'package:graduation_project/screens/bag_tracking/order_review_screen.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyDialogContent(
      serviceName: "Bag Tracking",
      onAccept: () {
        print("User accepted Bag Tracking terms");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderReviewScreen()),
        );
      },
    );
  }
}
