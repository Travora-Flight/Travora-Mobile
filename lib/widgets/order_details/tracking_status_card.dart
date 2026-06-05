import 'package:flutter/material.dart';

class TrackingStep {
  final String title;
  final String subtitle;
  final String? dateTime;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;

  TrackingStep({
    required this.title,
    required this.subtitle,
    this.dateTime,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isPending = false,
  });
}

class TrackingStatusCard extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingStatusCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF274C77),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Status',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyLarge!.color!),
          ),
          const SizedBox(height: 35),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return _buildTrackingItem(
                context,
                steps[index],
                index == steps.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingItem(
      BuildContext context, TrackingStep step, bool isLast) {
    Color lineColor =
        step.isPending ? const Color(0xFFE5E9F0) : const Color(0xFF274C77);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildCustomStatusIcon(step),
              if (!isLast)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Container(
                      width: 2.2,
                      color: lineColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        step.isPending ? FontWeight.w500 : FontWeight.w600,
                    color: step.isPending
                        ? const Color(0xFFA6A6A6)
                        : Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.subtitle,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: step.isPending
                          ? const Color(0xFFA6A6A6)
                          : const Color(0xFF4A5565)),
                ),
                if (step.dateTime != null) ...[
                  const SizedBox(height: 4),
                  Text(step.dateTime!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFA6A6A6))),
                ],
                if (!isLast) const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStatusIcon(TrackingStep step) {
    if (step.isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
            color: Color(0xFF274C77), shape: BoxShape.circle),
        child: Center(
          child: Image.asset('assets/images/icon_done.png',
              width: 14, height: 14, fit: BoxFit.contain),
        ),
      );
    } else if (step.isCurrent) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF274C77), width: 2.5),
        ),
      );
    } else {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF99A1AF), width: 2),
        ),
      );
    }
  }
}
