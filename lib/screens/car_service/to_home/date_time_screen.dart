import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/order_details/date_time_selector.dart';
import 'package:graduation_project/screens/car_service/to_home/select_bags_screen.dart';
import 'package:graduation_project/services/car_service/slot_service.dart';
import 'package:graduation_project/models/servicess/car_service/slot.dart';
import 'package:intl/intl.dart';

class DeliveryDateTimeScreen extends StatefulWidget {
  const DeliveryDateTimeScreen({super.key});

  @override
  State<DeliveryDateTimeScreen> createState() => _DeliveryDateTimeScreenState();
}

class _DeliveryDateTimeScreenState extends State<DeliveryDateTimeScreen> {
  final SlotService _slotService = SlotService();

  int selectedDay = 0;
  int selectedTime = -1;

  bool isLoadingDays = true;
  bool isLoadingTimes = false;
  bool isLoadingNext = false;

  String errorMessage = '';

  List<Map<String, String>> days = [];
  List<DateTime> availableDateTimes = [];

  List<String> times = [];
  List<SlotItem> availableSlots = [];

  String selectedMonthYear = '';

  @override
  void initState() {
    super.initState();
    _fetchDates();
  }

  Future<void> _fetchDates() async {
    try {
      setState(() {
        isLoadingDays = true;
        errorMessage = '';
      });

      final result = await _slotService.fetchAvailableDates();

      if (!result.isValid || result.availableDates.isEmpty) {
        setState(() {
          errorMessage = result.errorMessage ?? 'No available dates.';
          isLoadingDays = false;
        });
        return;
      }

      availableDateTimes = result.availableDates;

      final List<Map<String, String>> mappedDays = availableDateTimes.map((dt) {
        return {
          'day': DateFormat('EEE').format(dt),
          'date': dt.day.toString(),
        };
      }).toList();

      setState(() {
        days = mappedDays;
        selectedMonthYear =
            DateFormat('MMM yyyy').format(availableDateTimes.first);
        isLoadingDays = false;
      });

      await _fetchSlots(0);
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoadingDays = false;
      });
    }
  }

  Future<void> _fetchSlots(int dayIndex) async {
    try {
      setState(() {
        isLoadingTimes = true;
        times = [];
        availableSlots = [];
        selectedTime = -1;
        errorMessage = '';
      });

      final selectedDate = availableDateTimes[dayIndex];
      final dateString = selectedDate.toUtc().toIso8601String();

      final result = await _slotService.fetchAvailableSlots(dateString);

      if (!result.isValid) {
        setState(() {
          errorMessage = result.errorMessage ?? 'No available slots.';
          isLoadingTimes = false;
        });
        return;
      }

      final available =
          result.availableSlots.where((s) => s.available).toList();

      setState(() {
        availableSlots = available;
        times = available.map((s) => s.slot).toList();
        isLoadingTimes = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoadingTimes = false;
      });
    }
  }

  Future<void> _selectSlot() async {
    if (selectedTime == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    try {
      setState(() => isLoadingNext = true);

      final selectedDate = availableDateTimes[selectedDay];
      final dateString = selectedDate.toUtc().toIso8601String();
      final slotString = availableSlots[selectedTime].slot;

      final result = await _slotService.selectSlot(
        slot: slotString,
        date: dateString,
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectBagsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to select slot, please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => isLoadingNext = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Date and Time",
          style: TextStyle(
            color: Color(0xFF274C77),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoadingDays
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF274C77)),
            )
          : errorMessage.isNotEmpty && days.isEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DateTimeSelector(
                        sectionTitle: "Choose Delivery Date",
                        selectedMonthYear: selectedMonthYear,
                        isLoadingTimes: isLoadingTimes,
                        days: days,
                        times: times,
                        selectedDayIndex: selectedDay,
                        selectedTimeIndex: selectedTime,
                        onDaySelected: (index) {
                          setState(() => selectedDay = index);
                          _fetchSlots(index);
                        },
                        onTimeSelected: (index) =>
                            setState(() => selectedTime = index),
                      ),
                      const SizedBox(height: 330),
                      _buildNextButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF274C77), Color(0xFFA3CEF1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoadingNext ? null : _selectSlot,
        child: isLoadingNext
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
