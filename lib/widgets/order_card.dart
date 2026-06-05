import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String iconPath;
  final String statusText;
  final Color statusColor;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.title,
    required this.orderId,
    required this.iconPath,
    required this.statusText,
    this.statusColor = const Color(0xFF274C77),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF274C77).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF274C77).withOpacity(0.20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(iconPath, width: 30, height: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D2733),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID : $orderId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7D94),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Color(0xFF6B7D94),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF274C77).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF274C77),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [Color(0xFFA3CEF1), Color(0xFF274C77)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF274C77).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_outward,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF4F6F8),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.inventory_2_outlined,
                          size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Order Details',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Text('Tap to view',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
