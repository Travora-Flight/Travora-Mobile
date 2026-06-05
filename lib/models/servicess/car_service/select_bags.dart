
class BagItem {
  final String tagNumber;
  final double weightKg;
  final String journey;
  final String gate;
  final String terminal;
  final String ticketNumber;
  bool isSelected;

  BagItem({
    required this.tagNumber,
    required this.weightKg,
    required this.journey,
    required this.gate,
    required this.terminal,
    required this.ticketNumber,
    this.isSelected = false,
  });

  factory BagItem.fromJson(Map<String, dynamic> json) {
    return BagItem(
      tagNumber: json['tagNumber'] ?? '',
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      journey: json['journey'] ?? '',
      gate: json['gate'] ?? '',
      terminal: json['terminal'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
    );
  }
}

class PassengerBags {
  final String passengerName;
  final String ticketNumber;
  final List<BagItem> bags;

  PassengerBags({
    required this.passengerName,
    required this.ticketNumber,
    required this.bags,
  });

  factory PassengerBags.fromJson(Map<String, dynamic> json) {
    return PassengerBags(
      passengerName: json['passengerName'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      bags: (json['bags'] as List<dynamic>? ?? [])
          .map((b) => BagItem.fromJson(b))
          .toList(),
    );
  }
}

class MyBagsResponse {
  final bool isValid;
  final List<PassengerBags> passengers;
  final String? errorMessage;

  MyBagsResponse({
    required this.isValid,
    required this.passengers,
    this.errorMessage,
  });

  factory MyBagsResponse.fromJson(Map<String, dynamic> json) {
    return MyBagsResponse(
      isValid: json['isValid'] ?? false,
      passengers: (json['passengers'] as List<dynamic>? ?? [])
          .map((p) => PassengerBags.fromJson(p))
          .toList(),
      errorMessage: json['errorMessage'],
    );
  }
}

class SelectBagsResponse {
  final bool success;
  final int selectedCount;

  SelectBagsResponse({
    required this.success,
    required this.selectedCount,
  });

  factory SelectBagsResponse.fromJson(Map<String, dynamic> json) {
    return SelectBagsResponse(
      success: json['success'] ?? false,
      selectedCount: json['selectedCount'] ?? 0,
    );
  }
}
