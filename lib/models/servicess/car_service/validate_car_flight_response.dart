class ValidateCarFlightResponse {
  final bool isValid;
  final FlightInfo? flightInfo;
  final PassengerInfo? passengerInfo;
  final int? baggageCount;
  final String? bookingDeadlineUtc;
  final String? serviceType;
  final String? errorMessage;

  ValidateCarFlightResponse({
    required this.isValid,
    this.flightInfo,
    this.passengerInfo,
    this.baggageCount,
    this.bookingDeadlineUtc,
    this.serviceType,
    this.errorMessage,
  });

  factory ValidateCarFlightResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCarFlightResponse(
      isValid: json['isValid'] ?? false,
      flightInfo: json['flightInfo'] != null
          ? FlightInfo.fromJson(json['flightInfo'])
          : null,
      passengerInfo: json['passengerInfo'] != null
          ? PassengerInfo.fromJson(json['passengerInfo'])
          : null,
      baggageCount: json['baggageCount'],
      bookingDeadlineUtc: json['bookingDeadlineUtc'],
      serviceType: json['serviceType'],
      errorMessage: json['errorMessage'],
    );
  }
}

class FlightInfo {
  final String? flightNumber;
  final String? departureAirport;
  final String? arrivalAirport;
  final String? terminal;
  final String? gate;
  final String? airlineName;
  final String? flightDate;
  final String? boardingTimeUtc;

  FlightInfo({
    this.flightNumber,
    this.departureAirport,
    this.arrivalAirport,
    this.terminal,
    this.gate,
    this.airlineName,
    this.flightDate,
    this.boardingTimeUtc,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) => FlightInfo(
        flightNumber: json['flightNumber'],
        departureAirport: json['departureAirport'],
        arrivalAirport: json['arrivalAirport'],
        terminal: json['terminal'],
        gate: json['gate'],
        airlineName: json['airlineName'],
        flightDate: json['flightDate'],
        boardingTimeUtc: json['boardingTimeUtc'],
      );
}

class PassengerInfo {
  final String? firstName;
  final String? lastName;
  final String? passportNumber;
  final String? seatNumber;
  final String? travelClass;
  final String? boardingStatus;

  PassengerInfo({
    this.firstName,
    this.lastName,
    this.passportNumber,
    this.seatNumber,
    this.travelClass,
    this.boardingStatus,
  });

  factory PassengerInfo.fromJson(Map<String, dynamic> json) => PassengerInfo(
        firstName: json['firstName'],
        lastName: json['lastName'],
        passportNumber: json['passportNumber'],
        seatNumber: json['seatNumber'],
        travelClass: json['travelClass'],
        boardingStatus: json['boardingStatus'],
      );
}
