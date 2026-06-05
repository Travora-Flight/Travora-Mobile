class ValidateFlightRequest {
  final String ticketNumber;
  final String flightNumber;
  final String flightDate;
  final int baggageCount;

  ValidateFlightRequest({
    required this.ticketNumber,
    required this.flightNumber,
    required this.flightDate,
    required this.baggageCount,
  });

  Map<String, dynamic> toJson() => {
        "ticketNumber": ticketNumber,
        "flightNumber": flightNumber,
        "flightDate": flightDate,
        "baggageCount": baggageCount,
      };
}
