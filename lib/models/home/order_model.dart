class OrderModel {
  final String orderId;
  final String status;
  final int baggageCount;
  final String totalAmount;

  OrderModel({
    required this.orderId,
    required this.status,
    required this.baggageCount,
    required this.totalAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['OrderId']?.toString() ?? '',
      status: json['OrderStatus'] ?? 'Pending',
      baggageCount: json['TotalBaggage_Count'] is int
          ? json['TotalBaggageCount']
          : int.tryParse(json['TotalBaggageCount']?.toString() ?? '0') ?? 0,
      totalAmount: json['TotalAmount']?.toString() ?? '0.0',
    );
  }
}
