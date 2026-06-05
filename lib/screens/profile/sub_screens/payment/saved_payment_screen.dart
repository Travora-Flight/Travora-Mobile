import 'package:flutter/material.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/models/profile/payment_model.dart';
import 'package:graduation_project/services/payment_service/payment_service.dart';

class SavedPaymentScreen extends StatefulWidget {
  final PaymentCardModel? paymentMethod;
  const SavedPaymentScreen({
    super.key,
    this.paymentMethod,
  });

  @override
  State<SavedPaymentScreen> createState() => _SavedPaymentScreenState();
}

class _SavedPaymentScreenState extends State<SavedPaymentScreen> {
  final PaymentService _paymentService = PaymentService();

  void _showDeletePaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDEBED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDE332A),
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Delete Payment?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to Delete your payment information? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.paymentMethod != null) {
                      String? errorMessage =
                          await _paymentService.deletePaymentMethod(
                              widget.paymentMethod!.paymentMethodId);

                      if (errorMessage == null) {
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                        }
                      } else {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE332A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Yes, Delete",
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFF274C77), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "No, Keep It",
                    style: TextStyle(
                        color: Color(0xFF274C77),
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayHolderName =
        widget.paymentMethod?.cardHolderName ?? "Sophia Carter";
    final String displayCardNumber = widget.paymentMethod != null
        ? "**** **** **** ${widget.paymentMethod!.cardLastFour}"
        : "2543 4458 4861 5168";
    final String displayExpiry = widget.paymentMethod != null
        ? "${widget.paymentMethod!.expiryMonth}/${widget.paymentMethod!.expiryYear}"
        : "06/30";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Information',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [], 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreditCardView(context, displayHolderName, displayCardNumber),
            const SizedBox(height: 30),
            _buildLabeledField(context, "Card Holder Name", displayHolderName),
            const SizedBox(height: 20),
            _buildLabeledField(context, "Card Number", displayCardNumber),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildLabeledField(
                        context, "Expiry Date", displayExpiry)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledField(context, "CVV", "***")),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 48),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.mainGradient,
                  boxShadow: AppColors.buttonShadow,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.paymentMethod != null) {
                      bool success =
                          await _paymentService.setDefaultPaymentMethod(
                              widget.paymentMethod!.paymentMethodId);

                      if (success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Card set as main successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context, true);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to set card as main"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Set as default",
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _showDeletePaymentDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF274C77), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    "Delete card",
                    style: TextStyle(
                      color: Color(0xFF274C77),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardView(
      BuildContext context, String name, String number) {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.paymentMethod?.paymentFunding ?? "Credit",
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 13)),
              Text(widget.paymentMethod?.cardBrand ?? "VISA",
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFC0A060),
                borderRadius: BorderRadius.circular(5)),
            child: Image.asset(
              'assets/images/visa_icon.png',
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.credit_card, color: Colors.white),
            ),
          ),
          const Spacer(),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text(
              name,
              style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(number,
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 16,
                      letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF274C77).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7B7B7B),
            ),
          ),
        ),
      ],
    );
  }
}
