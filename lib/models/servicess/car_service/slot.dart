
class AvailableDatesResponse {
  final bool isValid;
  final List<DateTime> availableDates;
  final String? errorMessage;

  AvailableDatesResponse({
    required this.isValid,
    required this.availableDates,
    this.errorMessage,
  });

  factory AvailableDatesResponse.fromJson(Map<String, dynamic> json) {
    return AvailableDatesResponse(
      isValid: json['isValid'] ?? false,
      availableDates: (json['availableDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e.toString()))
              .toList() ??
          [],
      errorMessage: json['errorMessage'],
    );
  }
}

// ============================================================

class SlotItem {
  final String slot;
  final bool available;

  SlotItem({
    required this.slot,
    required this.available,
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    return SlotItem(
      slot: json['slot'] ?? '',
      available: json['available'] ?? false,
    );
  }
}



class AvailableSlotsResponse {
  final bool isValid;
  final String? errorMessage;
  final List<SlotItem> availableSlots;
  final String? cutoffTime;
  final String? note;

  AvailableSlotsResponse({
    required this.isValid,
    this.errorMessage,
    required this.availableSlots,
    this.cutoffTime,
    this.note,
  });

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResponse(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      availableSlots: (json['availableSlots'] as List<dynamic>?)
              ?.map((e) => SlotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cutoffTime: json['cutoffTime'],
      note: json['note'],
    );
  }
}


class SelectSlotResponse {
  final bool success;
  final String? selectedSlot;
  final String? date;

  SelectSlotResponse({
    required this.success,
    this.selectedSlot,
    this.date,
  });

  factory SelectSlotResponse.fromJson(Map<String, dynamic> json) {
    return SelectSlotResponse(
      success: json['success'] ?? false,
      selectedSlot: json['selectedSlot'],
      date: json['date'],
    );
  }
}
