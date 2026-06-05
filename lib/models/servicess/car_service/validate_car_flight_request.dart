class ValidateCarFlightRequest {
  final String ticketNumber;
  final String flightNumber;
  final String flightDate;
  final int baggageCount;
  final String serviceType; 

  ValidateCarFlightRequest({
    required this.ticketNumber,
    required this.flightNumber,
    required this.flightDate,
    required this.baggageCount,
    required this.serviceType,
  });

  Map<String, dynamic> toJson() => {
        "ticketNumber": ticketNumber,
        "flightNumber": flightNumber,
        "flightDate": flightDate,
        "baggageCount": baggageCount,
        "serviceType": serviceType,
      };
}
