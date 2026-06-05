
class OrderModel {
  final int orderId;
  final String packageName;
  final String orderStatus;
  final String createdAt;
  final double totalAmount;
  final String from;
  final String to;

  OrderModel({
    required this.orderId,
    required this.packageName,
    required this.orderStatus,
    required this.createdAt,
    required this.totalAmount,
    required this.from,
    required this.to,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? 0,
      packageName: json['packageName'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}
