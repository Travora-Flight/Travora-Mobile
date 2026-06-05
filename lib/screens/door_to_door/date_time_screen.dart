import 'package:flutter/material.dart';
import 'package:graduation_project/models/servicess/door_to_door/slot.dart';
import 'package:graduation_project/services/door_to_door_service/slot_service.dart';
import 'package:graduation_project/widgets/order_details/date_time_selector.dart';
import 'declaration_screen.dart';

class DateTimeScreen extends StatefulWidget {
  const DateTimeScreen({super.key});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  final SlotService _slotService = SlotService();

  int selectedPickupDay = 0;
  int selectedPickupTime = 0;
  List<Map<String, String>> pickupDays = [];
  List<String> pickupTimes = [];
  bool isLoadingPickupDays = false;
  bool isLoadingPickup = false;
  String? pickupNote;

  int selectedDeliveryDay = 0;
  int selectedDeliveryTime = 0;
  List<Map<String, String>> deliveryDays = [];
  List<String> deliveryTimes = [];
  bool isLoadingDeliveryDays = false;
  bool isLoadingDelivery = false;
  String? deliveryNote;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchPickupDates();
    _fetchDeliveryDates();
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, String> _dateStringToMap(String dateStr) {
    final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
    return {
      'day': _getDayName(dt.weekday),
      'date': dt.day.toString(),
      'fullDate': _formatDate(dt),
    };
  }

  String _getMonthYear(List<Map<String, String>> days) {
    if (days.isEmpty) return '';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final fullDate = days[0]['fullDate'] ?? '';
    final dt = DateTime.tryParse(fullDate);
    if (dt == null) return '';
    return '${months[dt.month]} ${dt.year}';
  }

  Future<void> _fetchPickupDates() async {
    setState(() => isLoadingPickupDays = true);
    try {
      final res = await _slotService.getAvailablePickupDates();
      setState(() {
        pickupDays =
            res.availableDates.map((d) => _dateStringToMap(d)).toList();
        selectedPickupDay = 0;
      });
      if (pickupDays.isNotEmpty) _fetchPickupSlots(0);
    } catch (_) {
      _showError('Failed to load pickup dates');
    } finally {
      setState(() => isLoadingPickupDays = false);
    }
  }

  Future<void> _fetchDeliveryDates() async {
    setState(() => isLoadingDeliveryDays = true);
    try {
      final res = await _slotService.getAvailableDeliveryDates();
      setState(() {
        deliveryDays =
            res.availableDates.map((d) => _dateStringToMap(d)).toList();
        selectedDeliveryDay = 0;
      });
      if (deliveryDays.isNotEmpty) _fetchDeliverySlots(0);
    } catch (_) {
      _showError('Failed to load delivery dates');
    } finally {
      setState(() => isLoadingDeliveryDays = false);
    }
  }

  Future<void> _fetchPickupSlots(int dayIndex) async {
    setState(() {
      isLoadingPickup = true;
      pickupTimes = [];
    });
    try {
      final res = await _slotService.getAvailablePickupSlots(
        date: pickupDays[dayIndex]['fullDate']!,
      );
      setState(() {
        pickupTimes = res.availableSlots
            .where((s) => s.available)
            .map((s) => s.slot)
            .toList();
        pickupNote = res.note;
        selectedPickupTime = 0;
      });
    } catch (_) {
      _showError('Failed to load pickup slots');
    } finally {
      setState(() => isLoadingPickup = false);
    }
  }

  Future<void> _fetchDeliverySlots(int dayIndex) async {
    setState(() {
      isLoadingDelivery = true;
      deliveryTimes = [];
    });
    try {
      final res = await _slotService.getAvailableDeliverySlots(
        date: deliveryDays[dayIndex]['fullDate']!,
      );
      setState(() {
        deliveryTimes = res.availableSlots
            .where((s) => s.available)
            .map((s) => s.slot)
            .toList();
        deliveryNote = res.note;
        selectedDeliveryTime = 0;
      });
    } catch (_) {
      _showError('Failed to load delivery slots');
    } finally {
      setState(() => isLoadingDelivery = false);
    }
  }

  Future<void> _onNext() async {
    if (pickupTimes.isEmpty || deliveryTimes.isEmpty) {
      _showError('Please select pickup and delivery times');
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final pickupRes = await _slotService.selectPickupSlot(
        slot: pickupTimes[selectedPickupTime],
        date: pickupDays[selectedPickupDay]['fullDate']!,
      );
      if (!pickupRes.success) {
        _showError('Failed to confirm pickup');
        return;
      }

      final deliveryRes = await _slotService.selectDeliverySlot(
        slot: deliveryTimes[selectedDeliveryTime],
        date: deliveryDays[selectedDeliveryDay]['fullDate']!,
      );
      if (!deliveryRes.success) {
        _showError('Failed to confirm delivery');
        return;
      }

      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DeclarationScreen()));
      }
    } catch (_) {
      _showError('Something went wrong, please try again');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Date And Time",
            style: TextStyle(
                color: Color(0xFF274C77), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoadingPickupDays && isLoadingDeliveryDays
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateTimeSelector(
                    sectionTitle: "Choose PickUp Date",
                    selectedMonthYear: _getMonthYear(pickupDays),
                    days: pickupDays,
                    times: pickupTimes,
                    isLoadingTimes: isLoadingPickup,
                    selectedDayIndex: selectedPickupDay,
                    selectedTimeIndex: selectedPickupTime,
                    onDaySelected: (i) {
                      setState(() => selectedPickupDay = i);
                      _fetchPickupSlots(i);
                    },
                    onTimeSelected: (i) =>
                        setState(() => selectedPickupTime = i),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Note: pickup date and time must be selected 12h before Departure",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  if (pickupNote != null && pickupNote!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(pickupNote!,
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12)),
                  ],
                  const SizedBox(height: 25),

                  DateTimeSelector(
                    sectionTitle: "Choose Delivery Date",
                    selectedMonthYear: _getMonthYear(deliveryDays),
                    days: deliveryDays,
                    times: deliveryTimes,
                    isLoadingTimes: isLoadingDelivery,
                    selectedDayIndex: selectedDeliveryDay,
                    selectedTimeIndex: selectedDeliveryTime,
                    onDaySelected: (i) {
                      setState(() => selectedDeliveryDay = i);
                      _fetchDeliverySlots(i);
                    },
                    onTimeSelected: (i) =>
                        setState(() => selectedDeliveryTime = i),
                  ),
                  const SizedBox(height: 40),
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
            colors: [Color(0xFF274C77), Color(0xFFA3CEF1)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _onNext,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Next",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
      ),
    );
  }
}
