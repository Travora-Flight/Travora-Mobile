import 'package:flutter/material.dart';
import 'package:graduation_project/screens/profile/sub_screens/payment/add_new_card_screen.dart';

class OrderReviewWidget extends StatefulWidget {
  final String serviceName;
  final String userName;
  final String lastFourDigits;
  final Map<String, String> fees;
  final Function(String total) onPayPressed;

  const OrderReviewWidget({
    super.key,
    required this.serviceName,
    required this.userName,
    required this.lastFourDigits,
    required this.fees,
    required this.onPayPressed,
  });

  @override
  State<OrderReviewWidget> createState() => _OrderReviewWidgetState();
}

class _OrderReviewWidgetState extends State<OrderReviewWidget> {
  final TextEditingController _commentController = TextEditingController();
  String _savedComment = "Comment";

  int _selectedPaymentMethod = 0;

  static const Color darkBlue = Color(0xFF274C77);
  static final Color cardBgColor = const Color(0xFF274C77).withOpacity(0.25);

  double _calculateTotal() {
    double total = 0;
    widget.fees.forEach((key, value) {
      total += double.tryParse(value) ?? 0;
    });
    return total;
  }

  void _showCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD9E2EC),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: darkBlue, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Comment",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue)),
                const SizedBox(height: 15),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Type here",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: darkBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel",
                            style: TextStyle(color: darkBlue)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [darkBlue, Color(0xFFA3CEF1)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _savedComment = _commentController.text.isEmpty
                                  ? "Comment"
                                  : _commentController.text;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent),
                          child: const Text("Save",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _calculateTotal();
    final String formattedTotal = totalAmount.toStringAsFixed(2);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildCardContainer(
                  child: Column(
                    children: [
                      Text("\$$formattedTotal",
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text(widget.serviceName,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _buildCardContainer(
                  child: Column(
                    children: widget.fees.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14)),
                            Text("\$${entry.value}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedPaymentMethod = 0),
                  child: _buildCardContainer(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9E2EC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: darkBlue, width: 2),
                          ),
                          child: const Center(
                            child: Text("VISA",
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text("**** **** **** ${widget.lastFourDigits}",
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddNewCardScreen(),
                                ),
                              );
                            },
                            child: const Text("Change",
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline))),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod =
                          (_selectedPaymentMethod == 1) ? 0 : 1;
                    });
                  },
                  child: _buildCardContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Cash on Delivery",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        Icon(
                          _selectedPaymentMethod == 1
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: darkBlue,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showCommentDialog(context),
                  child: _buildCardContainer(
                    child: Row(
                      children: [
                        const Icon(Icons.add_comment_outlined,
                            color: darkBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(_savedComment,
                                style: const TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 10),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [darkBlue, Color(0xFFA3CEF1)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              onPressed: () => widget.onPayPressed(formattedTotal),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text("Pay \$$formattedTotal",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBlue, width: 1.0)),
      child: child,
    );
  }
}
