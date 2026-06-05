import 'package:flutter/material.dart';

class OrderSuccessWidget extends StatelessWidget {
  final String orderNumber;
  final String numberOfBags;
  final String customerName;
  final String totalAmount;
  final VoidCallback onBackHomePressed;

  const OrderSuccessWidget({
    super.key,
    required this.orderNumber,
    required this.numberOfBags,
    required this.customerName,
    required this.totalAmount,
    required this.onBackHomePressed,
  });

  static const Color darkBlue = Color(0xFF274C77);
  static const Color successGreen = Color(0xFF2DC937);
  static const Color lightGreenBg = Color(0xFFE8F9EB);
  static const Color borderColor = Color(0xFF274C77);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 80, color: successGreen),
                      const SizedBox(height: 20),
                      const Text(
                        "Order\nConfirmed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Your luggage transfer has been\nsuccessfully booked",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: lightGreenBg,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: successGreen.withOpacity(0.5), width: 1),
                        ),
                        child: Column(
                          children: [
                            const Text("Order Number",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              orderNumber,
                              style: const TextStyle(
                                  color: successGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Order Summary",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 20),
                      _buildSummaryRow("Number of Bags", "$numberOfBags bags"),
                      Divider(
                          height: 30,
                          color: Colors.grey.shade200,
                          thickness: 1),
                      _buildSummaryRow("Customer Name", customerName),
                      Divider(
                          height: 30,
                          color: Colors.grey.shade200,
                          thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text("\$$totalAmount",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [darkBlue, Color(0xFFA3CEF1)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              onPressed: onBackHomePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Back Home",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400)),
        Text(value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ],
    );
  }
}
