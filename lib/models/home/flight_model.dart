class FlightModel {
  final String flightNumber;
  final String flightStatus;
  final String departureIataCode;
  final String arrivalIataCode;
  final String airlineName;
  final String aircraftRegistrationNumber;
  final String scheduledArrivalTime;
  final String airlineLogoUrl;
  final double liveProgress;

  FlightModel({
    required this.flightNumber,
    required this.flightStatus,
    required this.departureIataCode,
    required this.arrivalIataCode,
    required this.airlineName,
    required this.aircraftRegistrationNumber,
    required this.scheduledArrivalTime,
    //airline
    required this.airlineLogoUrl,
    //additional
    required this.liveProgress,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      flightNumber: json['FlightNumber'] ?? 'N/A',
      flightStatus: json['FlightStatus'] ?? 'Unknown',
      departureIataCode: json['DepartureIataCode'] ?? '---',
      arrivalIataCode: json['ArrivalIataCode'] ?? '---',
      airlineName: json['AirlineName'] ?? 'Unknown',
      aircraftRegistrationNumber: json['AircraftRegistrationNumber'] ?? '',
      scheduledArrivalTime: json['ScheduledArrivalTime'] ?? '',
      airlineLogoUrl: json['LogoUrl'] ?? '',
      liveProgress: (json['LiveProgress'] ?? 0.0).toDouble(),
    );
  }
}
