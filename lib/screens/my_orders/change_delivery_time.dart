import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/order_details/date_time_selector.dart';
import '../../../services/orders/available_slots_service.dart';
import 'details/car_home_details_screen.dart';

class ChangeDeliveryTimeScreen extends StatefulWidget {
  final int orderId;
  final String? deliveryDate;

  const ChangeDeliveryTimeScreen({
    super.key,
    required this.orderId,
    this.deliveryDate,
  });

  @override
  State<ChangeDeliveryTimeScreen> createState() =>
      _ChangeDeliveryTimeScreenState();
}

class _ChangeDeliveryTimeScreenState extends State<ChangeDeliveryTimeScreen> {
  final AvailableSlotsService _service = AvailableSlotsService();

  int selectedDay = 0;
  int selectedTime = 0;
  bool _isLoadingDates = false;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  List<DateTime> _availableDates = [];
  List<String> _availableSlots = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    setState(() => _isLoadingDates = true);
    try {
      final result = await _service.getAvailableDates(
        orderId: widget.orderId,
        type: 'Delivery',
      );
      setState(() {
        _availableDates = result.availableDates;
        _isLoadingDates = false;
        if (_availableDates.isNotEmpty) {
          selectedDate = _availableDates[0];
          _loadSlots(selectedDate);
        }
      });
    } catch (e) {
      setState(() => _isLoadingDates = false);
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() => _isLoadingSlots = true);
    try {
      final result = await _service.getAvailableSlots(
        orderId: widget.orderId,
        type: 'Delivery',
        date: date.toUtc().toIso8601String(),
      );
      setState(() {
        _availableSlots = result.availableSlots
            .where((s) => s.available)
            .map((s) => s.slot)
            .toList();
        _isLoadingSlots = false;
        selectedTime = 0;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
    }
  }

  List<Map<String, String>> _datesToDaysList(List<DateTime> dates) {
    return dates
        .map((date) => {
              'day': DateFormat('E').format(date),
              'date': date.day.toString(),
            })
        .toList();
  }

  Future<void> _submit() async {
    if (_availableSlots.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await _service.reschedule(
        orderId: widget.orderId,
        type: 'Delivery',
        newDate: selectedDate.toUtc().toIso8601String(),
        newTimeSlot: _availableSlots[selectedTime],
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CarHomeDetailsScreen(orderId: widget.orderId),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDays = _datesToDaysList(_availableDates);
    final displayMonthYear = _availableDates.isNotEmpty
        ? DateFormat('MMMM yyyy').format(_availableDates[0])
        : DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Change Date and time",
          style:
              TextStyle(color: Color(0xFF274C77), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF274C77), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingDates
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF274C77)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DateTimeSelector(
                            sectionTitle: "Choose Delivery Date",
                            selectedMonthYear: displayMonthYear,
                            isLoadingTimes: _isLoadingSlots,
                            days: deliveryDays,
                            times: _availableSlots,
                            selectedDayIndex: selectedDay,
                            selectedTimeIndex: selectedTime,
                            onDaySelected: (i) {
                              if (i < _availableDates.length) {
                                setState(() {
                                  selectedDay = i;
                                  selectedDate = _availableDates[i];
                                });
                                _loadSlots(selectedDate);
                              }
                            },
                            onTimeSelected: (i) =>
                                setState(() => selectedTime = i),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  _buildButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildButton() => GestureDetector(
        onTap: _isSubmitting ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF274C77), Color(0xFF6B8AB4)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Next",
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      );
}
