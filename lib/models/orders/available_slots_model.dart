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

class AvailableSlotsModel {
  final bool isValid;
  final String? errorMessage;
  final List<SlotModel> availableSlots;
  final String? cutoffTime;
  final String? note;

  AvailableSlotsModel({
    required this.isValid,
    this.errorMessage,
    required this.availableSlots,
    this.cutoffTime,
    this.note,
  });

  factory AvailableSlotsModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsModel(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      availableSlots: (json['availableSlots'] as List<dynamic>? ?? [])
          .map((e) => SlotModel.fromJson(e))
          .toList(),
      cutoffTime: json['cutoffTime'],
      note: json['note'],
    );
  }
}

class AvailableDatesModel {
  final bool isValid;
  final List<DateTime> availableDates;
  final String? errorMessage;

  AvailableDatesModel({
    required this.isValid,
    required this.availableDates,
    this.errorMessage,
  });

  factory AvailableDatesModel.fromJson(Map<String, dynamic> json) {
    return AvailableDatesModel(
      isValid: json['isValid'] ?? false,
      availableDates: (json['availableDates'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e.toString()))
          .toList(),
      errorMessage: json['errorMessage'],
    );
  }
}

class RescheduleResponseModel {
  final bool success;
  final String? newDate;
  final String? newTimeSlot;
  final String? message;

  RescheduleResponseModel({
    required this.success,
    this.newDate,
    this.newTimeSlot,
    this.message,
  });

  factory RescheduleResponseModel.fromJson(Map<String, dynamic> json) {
    return RescheduleResponseModel(
      success: json['success'] ?? false,
      newDate: json['newDate'],
      newTimeSlot: json['newTimeSlot'],
      message: json['message'],
    );
  }
}
