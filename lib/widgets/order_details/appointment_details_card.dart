import 'package:flutter/material.dart';

class AppointmentDetailsCard extends StatelessWidget {
  final String title;
  final String sectionOneTitle;
  final String sectionOneDate;
  final String sectionOneTime;

  final String? sectionTwoTitle;
  final String? sectionTwoDate;
  final String? sectionTwoTime;

  final VoidCallback? onChangeDate;

  const AppointmentDetailsCard({
    super.key,
    this.title = 'Appointment',
    required this.sectionOneTitle,
    required this.sectionOneDate,
    required this.sectionOneTime,
    this.sectionTwoTitle,
    this.sectionTwoDate,
    this.sectionTwoTime,
    this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF274C77),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge!.color!),
              ),
              if (onChangeDate != null)
                GestureDetector(
                  onTap: onChangeDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF274C77), Color(0xFF6B8AB4)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Change Date',
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 25),
          if (sectionTwoTitle != null) ...[
            _buildSectionTitle(context, sectionOneTitle),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
              context, Icons.calendar_today_outlined, 'Date', sectionOneDate),
          const SizedBox(height: 18),
          _buildInfoRow(context, Icons.access_time, 'Time', sectionOneTime),
          if (sectionTwoTitle != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFFE5E9F0), thickness: 1.2),
            ),
            _buildSectionTitle(context, sectionTwoTitle!),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.calendar_today_outlined, 'Date',
                sectionTwoDate ?? ''),
            const SizedBox(height: 18),
            _buildInfoRow(
                context, Icons.access_time, 'Time', sectionTwoTime ?? ''),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyLarge!.color!,
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF274C77)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFA6A6A6),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge!.color!),
            ),
          ],
        ),
      ],
    );
  }
}
