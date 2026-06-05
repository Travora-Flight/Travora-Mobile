import 'package:flutter/material.dart';

class DateTimeSelector extends StatelessWidget {
  final String sectionTitle;
  final String selectedMonthYear;
  final List<Map<String, String>> days;
  final List<String> times;
  final bool isLoadingTimes; 
  final int selectedDayIndex;
  final int selectedTimeIndex;
  final Function(int) onDaySelected;
  final Function(int) onTimeSelected;

  const DateTimeSelector({
    super.key,
    required this.sectionTitle,
    required this.selectedMonthYear,
    required this.days,
    required this.times,
    required this.isLoadingTimes,
    required this.selectedDayIndex,
    required this.selectedTimeIndex,
    required this.onDaySelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        Text(
          selectedMonthYear,
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              bool isSelected = index == selectedDayIndex;
              return GestureDetector(
                onTap: () => onDaySelected(index),
                child: Container(
                  width: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E5F3),
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF274C77), width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(days[index]['day']!,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 13)),
                      Text(days[index]['date']!,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        Text("Choose Time",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 12),

        isLoadingTimes
            ? const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF274C77)),
                ),
              )
            : times.isEmpty
                ? const SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        "No available slots for this day",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: times.length,
                    itemBuilder: (context, index) {
                      bool isSelected = index == selectedTimeIndex;
                      return GestureDetector(
                        onTap: () => onTimeSelected(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9E5F3),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF274C77), width: 2)
                                : null,
                          ),
                          child: Center(
                              child: Text(times[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13))),
                        ),
                      );
                    },
                  ),
      ],
    );
  }
}
