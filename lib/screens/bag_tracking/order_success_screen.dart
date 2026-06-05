import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/order_success_widget.dart';
import 'package:graduation_project/screens/home/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final String numberOfBags;
  final String customerName;
  final String totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.numberOfBags,
    required this.customerName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrderSuccessWidget(
          orderNumber: orderNumber,
          numberOfBags: numberOfBags,
          customerName: customerName,
          totalAmount: totalAmount,
          onBackHomePressed: () {
            final navigator = Navigator.of(context);

            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
