class SlotModel {
  final String slot;
  final bool available;

  SlotModel({required this.slot, required this.available});

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      slot: json['slot'] ?? '',
      available: json['available'] ?? false,
    );
  }
}

class AvailableSlotsResponse {
  final bool isValid;
  final String? errorMessage;
  final List<SlotModel> availableSlots;
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
      availableSlots: (json['availableSlots'] as List? ?? [])
          .map((e) => SlotModel.fromJson(e))
          .toList(),
      cutoffTime: json['cutoffTime'],
      note: json['note'],
    );
  }
}

class SelectSlotResponse {
  final bool success;
  final String? selectedSlot;
  final String? selectedDeliverySlot;
  final String? date;

  SelectSlotResponse({
    required this.success,
    this.selectedSlot,
    this.selectedDeliverySlot,
    this.date,
  });

  factory SelectSlotResponse.fromJson(Map<String, dynamic> json) {
    return SelectSlotResponse(
      success: json['success'] ?? false,
      selectedSlot: json['selectedSlot'],
      selectedDeliverySlot: json['selectedDeliverySlot'],
      date: json['date'],
    );
  }
}

class AvailableDatesResponse {
  final bool isValid;
  final List<String> availableDates;
  final String? errorMessage;

  AvailableDatesResponse({
    required this.isValid,
    required this.availableDates,
    this.errorMessage,
  });

  factory AvailableDatesResponse.fromJson(Map<String, dynamic> json) {
    return AvailableDatesResponse(
      isValid: json['isValid'] ?? false,
      availableDates: (json['availableDates'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      errorMessage: json['errorMessage'],
    );
  }
}
