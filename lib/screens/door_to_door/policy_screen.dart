import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/custom_policy_dialog.dart';
import 'package:graduation_project/screens/door_to_door/order_review_screen.dart';

class PolicyScreen extends StatelessWidget {
  final String serviceName;

  const PolicyScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return PolicyDialogContent(
      serviceName: serviceName,
      onAccept: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderReviewScreen()),
        );
      },
    );
  }
}
