import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color:
              Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.25),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/images/home_icon.png', 'Home'),
            _buildNavItem(
                1, 'assets/images/flight_tracker_Icon.png', 'Tracker'),
            _buildNavItem(
                2, 'assets/images/notifications_icon.png', 'Notification'),
            _buildNavItem(3, 'assets/images/my_orders_icon.png', 'Orders'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String imagePath, String label) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF274C77).withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            RepaintBoundary(
              child: SizedBox(
                width: (index == 2) ? 42 : 26,
                height: (index == 2) ? 42 : 26,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  cacheWidth: 250,
                  cacheHeight: 250,
                  color: const Color(0xFF274C77),
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, size: 24, color: Color(0xFF274C77)),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF274C77),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
