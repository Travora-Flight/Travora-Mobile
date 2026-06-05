import 'dart:convert';

class PaymentResponse {
  final double balance;
  final List<PaymentCardModel> paymentMethods;

  PaymentResponse({
    required this.balance,
    required this.paymentMethods,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      balance: (json['balance'] ?? 0).toDouble(),
      paymentMethods: (json['paymentMethods'] as List? ?? [])
          .map((item) => PaymentCardModel.fromJson(item))
          .toList(),
    );
  }
}

class PaymentCardModel {
  final int paymentMethodId;
  final String cardHolderName;
  final String cardLastFour;
  final String cardBrand;
  final int expiryMonth;
  final int expiryYear;
  final String paymentFunding;
  final bool isDefault;

  PaymentCardModel({
    required this.paymentMethodId,
    required this.cardHolderName,
    required this.cardLastFour,
    required this.cardBrand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.paymentFunding,
    required this.isDefault,
  });

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      paymentMethodId: json['paymentMethodId'] ?? 0,
      cardHolderName: json['cardHolderName'] ?? '',
      cardLastFour: json['cardLastFour'] ?? '',
      cardBrand: json['cardBrand'] ?? '',
      expiryMonth: json['cardExpiryMonth'] ?? 0,
      expiryYear: json['cardExpiryYear'] ?? 0,
      paymentFunding: json['paymentFunding'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
      'cardHolderName': cardHolderName,
      'cardLastFour': cardLastFour,
      'cardBrand': cardBrand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'paymentFunding': paymentFunding,
      'isDefault': isDefault,
    };
  }
}
