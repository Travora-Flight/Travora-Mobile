
class BoardingPassModel {
  final String airlineName;
  final String flightNumber;
  final String from;
  final String fromCity;
  final String to;
  final String toCity;
  final String duration;
  final String departureTime;
  final String arrivalTime;
  final String passengerName;
  final String seatNumber;
  final String terminal;
  final String gate;
  final String boardingClass;
  final String boardingTime;
  final String flightDate;
  final String barcodeData;

  BoardingPassModel({
    required this.airlineName,
    required this.flightNumber,
    required this.from,
    required this.fromCity,
    required this.to,
    required this.toCity,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    required this.passengerName,
    required this.seatNumber,
    required this.terminal,
    required this.gate,
    required this.boardingClass,
    required this.boardingTime,
    required this.flightDate,
    required this.barcodeData,
  });

  factory BoardingPassModel.fromJson(Map<String, dynamic> json) {
    return BoardingPassModel(
      airlineName: json['airlineName'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      from: json['from'] ?? '',
      fromCity: json['fromCity'] ?? '',
      to: json['to'] ?? '',
      toCity: json['toCity'] ?? '',
      duration: json['duration'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      passengerName: json['passengerName'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      terminal: json['terminal'] ?? '',
      gate: json['gate'] ?? '',
      boardingClass: json['class'] ?? '',
      boardingTime: json['boardingTime'] ?? '',
      flightDate: json['flightDate'] ?? '',
      barcodeData: json['barcodeData'] ?? '',
    );
  }
}
