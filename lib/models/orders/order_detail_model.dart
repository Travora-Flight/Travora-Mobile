
class TrackingStepModel {
  final String step;
  final String description;
  final String? timestamp;
  final bool isDone;

  TrackingStepModel({
    required this.step,
    required this.description,
    this.timestamp,
    required this.isDone,
  });

  factory TrackingStepModel.fromJson(Map<String, dynamic> json) {
    return TrackingStepModel(
      step: json['step'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'],
      isDone: json['isDone'] ?? false,
    );
  }
}

class AppointmentModel {
  final String date;
  final String time;

  AppointmentModel({required this.date, required this.time});

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class OrderDetailModel {
  final int orderId;
  final String packageName;
  final String status;
  final String from;
  final String to;
  final int numberOfBags;
  final double totalWeight;
  final int numberOfPassengers;
  final bool canCancel;
  final bool hasBoardingPass;
  final AppointmentModel? pickup;
  final AppointmentModel? delivery;
  final List<TrackingStepModel> trackingStatus;

  OrderDetailModel({
    required this.orderId,
    required this.packageName,
    required this.status,
    required this.from,
    required this.to,
    required this.numberOfBags,
    required this.totalWeight,
    required this.numberOfPassengers,
    required this.canCancel,
    required this.hasBoardingPass,
    this.pickup,
    this.delivery,
    required this.trackingStatus,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final appointment = json['appointment'];
    return OrderDetailModel(
      orderId: json['orderId'] ?? 0,
      packageName: json['packageName'] ?? '',
      status: json['status'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      numberOfBags: json['numberOfBags'] ?? 0,
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      numberOfPassengers: json['numberOfPassengers'] ?? 0,
      canCancel: json['canCancel'] ?? false,
      hasBoardingPass: json['hasBoardingPass'] ?? false,
      pickup: appointment?['pickup'] != null
          ? AppointmentModel.fromJson(appointment['pickup'])
          : null,
      delivery: appointment?['delivery'] != null
          ? AppointmentModel.fromJson(appointment['delivery'])
          : null,
      trackingStatus: (json['trackingStatus'] as List<dynamic>? ?? [])
          .map((e) => TrackingStepModel.fromJson(e))
          .toList(),
    );
  }
}
