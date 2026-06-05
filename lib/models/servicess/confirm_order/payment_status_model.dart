class PaymentStatusModel {
  final int orderId;
  final String orderStatus;
  final String invoiceStatus;
  final double amount;
  final String? paidAt;

  PaymentStatusModel({
    required this.orderId,
    required this.orderStatus,
    required this.invoiceStatus,
    required this.amount,
    this.paidAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      orderId: json['orderId'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      invoiceStatus: json['invoiceStatus'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidAt: json['paidAt'],
    );
  }

  bool get isPaid => invoiceStatus.toLowerCase() == 'paid';
}
