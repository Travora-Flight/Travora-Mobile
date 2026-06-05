import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/order_details/date_time_selector.dart';
import '../../../services/orders/available_slots_service.dart';
import 'details/door_to_door_details_screen.dart';

class ChangeDoorToDoorTimeScreen extends StatefulWidget {
  final int orderId;
  final String? pickupDate;
  final String? deliveryDate;

  const ChangeDoorToDoorTimeScreen({
    super.key,
    required this.orderId,
    this.pickupDate,
    this.deliveryDate,
  });

  @override
  State<ChangeDoorToDoorTimeScreen> createState() =>
      _ChangeDoorToDoorTimeScreenState();
}

class _ChangeDoorToDoorTimeScreenState
    extends State<ChangeDoorToDoorTimeScreen> {
  final AvailableSlotsService _service = AvailableSlotsService();

  int selPickDay = 0;
  int selPickTime = 0;
  int selDelDay = 0;
  int selDelTime = 0;

  bool _isLoadingPickupDates = false;
  bool _isLoadingDeliveryDates = false;
  bool _isLoadingPickup = false;
  bool _isLoadingDelivery = false;
  bool _isSubmitting = false;

  List<DateTime> _pickupDates = [];
  List<DateTime> _deliveryDates = [];
  List<String> _pickupSlots = [];
  List<String> _deliverySlots = [];

  DateTime selectedPickupDate = DateTime.now();
  DateTime selectedDeliveryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPickupDates();
    _loadDeliveryDates();
  }

  Future<void> _loadPickupDates() async {
    setState(() => _isLoadingPickupDates = true);
    try {
      final result = await _service.getAvailableDates(
        orderId: widget.orderId,
        type: 'Pickup',
      );
      setState(() {
        _pickupDates = result.availableDates;
        _isLoadingPickupDates = false;
        if (_pickupDates.isNotEmpty) {
          selectedPickupDate = _pickupDates[0];
          _loadPickupSlots(selectedPickupDate);
        }
      });
    } catch (e) {
      setState(() => _isLoadingPickupDates = false);
    }
  }

  Future<void> _loadDeliveryDates() async {
    setState(() => _isLoadingDeliveryDates = true);
    try {
      final result = await _service.getAvailableDates(
        orderId: widget.orderId,
        type: 'Delivery',
      );
      setState(() {
        _deliveryDates = result.availableDates;
        _isLoadingDeliveryDates = false;
        if (_deliveryDates.isNotEmpty) {
          selectedDeliveryDate = _deliveryDates[0];
          _loadDeliverySlots(selectedDeliveryDate);
        }
      });
    } catch (e) {
      setState(() => _isLoadingDeliveryDates = false);
    }
  }

  Future<void> _loadPickupSlots(DateTime date) async {
    setState(() => _isLoadingPickup = true);
    try {
      final result = await _service.getAvailableSlots(
        orderId: widget.orderId,
        type: 'Pickup',
        date: date.toUtc().toIso8601String(),
      );
      setState(() {
        _pickupSlots = result.availableSlots
            .where((s) => s.available)
            .map((s) => s.slot)
            .toList();
        _isLoadingPickup = false;
        selPickTime = 0;
      });
    } catch (e) {
      setState(() => _isLoadingPickup = false);
    }
  }

  Future<void> _loadDeliverySlots(DateTime date) async {
    setState(() => _isLoadingDelivery = true);
    try {
      final result = await _service.getAvailableSlots(
        orderId: widget.orderId,
        type: 'Delivery',
        date: date.toUtc().toIso8601String(),
      );
      setState(() {
        _deliverySlots = result.availableSlots
            .where((s) => s.available)
            .map((s) => s.slot)
            .toList();
        _isLoadingDelivery = false;
        selDelTime = 0;
      });
    } catch (e) {
      setState(() => _isLoadingDelivery = false);
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
    if (_pickupSlots.isEmpty || _deliverySlots.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await _service.reschedule(
        orderId: widget.orderId,
        type: 'Pickup',
        newDate: selectedPickupDate.toUtc().toIso8601String(),
        newTimeSlot: _pickupSlots[selPickTime],
      );
      await _service.reschedule(
        orderId: widget.orderId,
        type: 'Delivery',
        newDate: selectedDeliveryDate.toUtc().toIso8601String(),
        newTimeSlot: _deliverySlots[selDelTime],
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DoorToDoorDetailsScreen(orderId: widget.orderId),
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
    final pickupDays = _datesToDaysList(_pickupDates);
    final deliveryDays = _datesToDaysList(_deliveryDates);
    final displayMonthYear = _pickupDates.isNotEmpty
        ? DateFormat('MMMM yyyy').format(_pickupDates[0])
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
      body: _isLoadingPickupDates || _isLoadingDeliveryDates
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF274C77)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          DateTimeSelector(
                            sectionTitle: "Choose PickUp Date",
                            selectedMonthYear: displayMonthYear,
                            isLoadingTimes: _isLoadingPickup,
                            days: pickupDays,
                            times: _pickupSlots,
                            selectedDayIndex: selPickDay,
                            selectedTimeIndex: selPickTime,
                            onDaySelected: (i) {
                              if (i < _pickupDates.length) {
                                setState(() {
                                  selPickDay = i;
                                  selectedPickupDate = _pickupDates[i];
                                });
                                _loadPickupSlots(selectedPickupDate);
                              }
                            },
                            onTimeSelected: (i) =>
                                setState(() => selPickTime = i),
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Note: pickup date and time must be selected 12h before Departure",
                              style: TextStyle(color: Colors.red, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 30),
                          DateTimeSelector(
                            sectionTitle: "Choose Delivery Date",
                            selectedMonthYear: displayMonthYear,
                            isLoadingTimes: _isLoadingDelivery,
                            days: deliveryDays,
                            times: _deliverySlots,
                            selectedDayIndex: selDelDay,
                            selectedTimeIndex: selDelTime,
                            onDaySelected: (i) {
                              if (i < _deliveryDates.length) {
                                setState(() {
                                  selDelDay = i;
                                  selectedDeliveryDate = _deliveryDates[i];
                                });
                                _loadDeliverySlots(selectedDeliveryDate);
                              }
                            },
                            onTimeSelected: (i) =>
                                setState(() => selDelTime = i),
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
              colors: [Color(0xFF274C77), Color(0xFF6B8AB4)],
            ),
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
