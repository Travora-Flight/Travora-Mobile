class ValidateFlightResponse {
  final bool isValid;
  final FlightInfo? flightInfo;
  final PassengerInfo? passengerInfo;
  final int? baggageCount;
  final String? bookingDeadlineUtc;
  final String? errorMessage;

  ValidateFlightResponse({
    required this.isValid,
    this.flightInfo,
    this.passengerInfo,
    this.baggageCount,
    this.bookingDeadlineUtc,
    this.errorMessage,
  });

  factory ValidateFlightResponse.fromJson(Map<String, dynamic> json) {
    return ValidateFlightResponse(
      isValid: json['isValid'] ?? false,
      flightInfo: json['flightInfo'] != null
          ? FlightInfo.fromJson(json['flightInfo'])
          : null,
      passengerInfo: json['passengerInfo'] != null
          ? PassengerInfo.fromJson(json['passengerInfo'])
          : null,
      baggageCount: json['baggageCount'],
      bookingDeadlineUtc: json['bookingDeadlineUtc'],
      errorMessage: json['errorMessage'],
    );
  }
}

class FlightInfo {
  final String? flightNumber;
  final String? departureAirport;
  final String? arrivalAirport;
  final String? departureTimeUtc;
  final String? arrivalTimeUtc;
  final String? terminal;
  final String? gate;
  final String? airlineName;
  final String? airlineIcaoCode;
  final String? departureIataCode;
  final String? arrivalIataCode;
  final String? originCity;
  final String? destinationCity;
  final String? flightDate;
  final String? flightDuration;
  final String? boardingTimeUtc;

  FlightInfo({
    this.flightNumber,
    this.departureAirport,
    this.arrivalAirport,
    this.departureTimeUtc,
    this.arrivalTimeUtc,
    this.terminal,
    this.gate,
    this.airlineName,
    this.airlineIcaoCode,
    this.departureIataCode,
    this.arrivalIataCode,
    this.originCity,
    this.destinationCity,
    this.flightDate,
    this.flightDuration,
    this.boardingTimeUtc,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      flightNumber: json['flightNumber'],
      departureAirport: json['departureAirport'],
      arrivalAirport: json['arrivalAirport'],
      departureTimeUtc: json['departureTimeUtc'],
      arrivalTimeUtc: json['arrivalTimeUtc'],
      terminal: json['terminal'],
      gate: json['gate'],
      airlineName: json['airlineName'],
      airlineIcaoCode: json['airlineIcaoCode'],
      departureIataCode: json['departureIataCode'],
      arrivalIataCode: json['arrivalIataCode'],
      originCity: json['originCity'],
      destinationCity: json['destinationCity'],
      flightDate: json['flightDate'],
      flightDuration: json['flightDuration'],
      boardingTimeUtc: json['boardingTimeUtc'],
    );
  }
}

class PassengerInfo {
  final String? firstName;
  final String? lastName;
  final String? passportNumber;
  final String? nationality;
  final String? dateOfBirth;
  final String? passportExpiryDate;
  final String? seatNumber;
  final String? travelClass;
  final String? boardingStatus;

  PassengerInfo({
    this.firstName,
    this.lastName,
    this.passportNumber,
    this.nationality,
    this.dateOfBirth,
    this.passportExpiryDate,
    this.seatNumber,
    this.travelClass,
    this.boardingStatus,
  });

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      firstName: json['firstName'],
      lastName: json['lastName'],
      passportNumber: json['passportNumber'],
      nationality: json['nationality'],
      dateOfBirth: json['dateOfBirth'],
      passportExpiryDate: json['passportExpiryDate'],
      seatNumber: json['seatNumber'],
      travelClass: json['travelClass'],
      boardingStatus: json['boardingStatus'],
    );
  }
}
