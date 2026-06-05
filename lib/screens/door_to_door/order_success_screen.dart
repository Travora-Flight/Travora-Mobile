import 'package:flutter/material.dart';
import '../../widgets/order_success_widget.dart';
import '../home/home_screen.dart'; 

class OrderSuccessScreen extends StatelessWidget {
  final String orderNo;
  final String bags;
  final String name;
  final String amount;

  const OrderSuccessScreen({
    super.key,
    required this.orderNo,
    required this.bags,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrderSuccessWidget(
          orderNumber: orderNo,
          numberOfBags: bags,
          customerName: name,
          totalAmount: amount,
          onBackHomePressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
