import 'package:flutter/material.dart';

class GenericOrderHeader extends StatelessWidget {
  final String title;
  final String orderId;
  final String status;
  final String iconPath;
  final String numberOfBags;
  final String? totalWeight;
  final String? vehicleType;
  final String? numOfPassengers;
  final String? fromLocation;
  final String? toLocation;

  const GenericOrderHeader({
    super.key,
    required this.title,
    required this.orderId,
    required this.status,
    required this.iconPath,
    required this.numberOfBags,
    this.totalWeight,
    this.vehicleType,
    this.numOfPassengers,
    this.fromLocation,
    this.toLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF274C77), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 30,
                    height: 30,
                    cacheWidth: 80,
                    cacheHeight: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_car,
                        color: Color(0xFF274C77)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyLarge!.color!),
                  ),
                  Text(
                    'ID : $orderId',
                    style:
                        const TextStyle(color: Color(0xFFA6A6A6), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Color(0xFFF0F0F0), thickness: 1),
          ),
          if (fromLocation != null && toLocation != null) ...[
            _buildLocationSection(context, 'From', fromLocation!),
            const SizedBox(height: 16),
            _buildLocationSection(context, 'To', toLocation!),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(color: Color(0xFFF0F0F0), thickness: 1),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(color: Color(0xFF4A5565), fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF274C77).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                      color: Color(0xFF274C77),
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDetailRow(context, 'Number of Bags', numberOfBags),
          if (totalWeight != null) ...[
            const SizedBox(height: 15),
            _buildDetailRow(context, 'Total Weight', totalWeight!),
          ],
          if (vehicleType != null) ...[
            const SizedBox(height: 15),
            _buildDetailRow(context, 'Vehicle Type', vehicleType!),
          ],
          if (numOfPassengers != null) ...[
            const SizedBox(height: 15),
            _buildDetailRow(context, 'Num of Passengers', numOfPassengers!),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection(
      BuildContext context, String label, String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined,
            size: 22, color: Color(0xFF274C77)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF4A5565), fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              fontWeight: FontWeight.w400,
              fontSize: 16),
        ),
      ],
    );
  }
}
