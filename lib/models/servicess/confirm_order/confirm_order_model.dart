class ConfirmOrderModel {
  final bool isValid;
  final bool success;
  final int orderId;
  final String orderNumber;
  final double totalPaid;
  final String? errorMessage;

  ConfirmOrderModel({
    required this.isValid,
    required this.success,
    required this.orderId,
    required this.orderNumber,
    required this.totalPaid,
    this.errorMessage,
  });

  factory ConfirmOrderModel.fromJson(Map<String, dynamic> json) {
    return ConfirmOrderModel(
      isValid: json['isValid'] ?? false,
      success: json['success'] ?? false,
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      errorMessage: json['errorMessage'],
    );
  }
}
