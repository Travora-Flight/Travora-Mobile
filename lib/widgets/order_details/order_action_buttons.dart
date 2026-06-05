import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/cancel_order_dialog.dart';

class OrderActions extends StatelessWidget {
  final bool showBoardingPass;
  final VoidCallback onCancel;
  final VoidCallback? onBoardingPass;

  const OrderActions({
    super.key,
    this.showBoardingPass = false,
    required this.onCancel,
    this.onBoardingPass,
  });

  @override
  Widget build(BuildContext context) {
    const double customRadius = 15.0;

    if (!showBoardingPass) {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF274C77), width: 1.8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(customRadius)),
          ),
          child: const Text("Cancel Order",
              style: TextStyle(
                  color: Color(0xFF274C77),
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF274C77), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(customRadius)),
                ),
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Color(0xFF274C77),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF274C77), Color(0xFF6B8AB4)]),
                borderRadius: BorderRadius.circular(customRadius),
              ),
              child: ElevatedButton(
                onPressed: onBoardingPass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(customRadius)),
                ),
                child: Text("Boarding Pass",
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      );
    }
  }
}
