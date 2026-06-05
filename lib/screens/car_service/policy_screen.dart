import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/custom_policy_dialog.dart';
import 'package:graduation_project/screens/car_service/order_review_screen.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyDialogContent(
      serviceName: "Car Service",
      onAccept: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CarServiceOrderReviewScreen(),
          ),
        );
      },
    );
  }
}
