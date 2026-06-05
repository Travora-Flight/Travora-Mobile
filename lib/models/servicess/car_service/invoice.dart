
class CarServiceBaggageDetails {
  final int includedBags;
  final int totalBags;
  final int extraBags;
  final double extraBaggageFee;

  CarServiceBaggageDetails({
    required this.includedBags,
    required this.totalBags,
    required this.extraBags,
    required this.extraBaggageFee,
  });

  factory CarServiceBaggageDetails.fromJson(Map<String, dynamic> json) {
    return CarServiceBaggageDetails(
      includedBags: json['includedBags'] ?? 0,
      totalBags: json['totalBags'] ?? 0,
      extraBags: json['extraBags'] ?? 0,
      extraBaggageFee: (json['extraBaggageFee'] ?? 0).toDouble(),
    );
  }
}

class CarServiceBreakdown {
  final double packageValue;
  final CarServiceBaggageDetails baggageDetails;
  final double customsValue;
  final double customsFee;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double totalAmount;

  CarServiceBreakdown({
    required this.packageValue,
    required this.baggageDetails,
    required this.customsValue,
    required this.customsFee,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.totalAmount,
  });

  factory CarServiceBreakdown.fromJson(Map<String, dynamic> json) {
    return CarServiceBreakdown(
      packageValue: (json['packageValue'] ?? 0).toDouble(),
      baggageDetails:
          CarServiceBaggageDetails.fromJson(json['baggageDetails'] ?? {}),
      customsValue: (json['customsValue'] ?? 0).toDouble(),
      customsFee: (json['customsFee'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class CarServiceInvoiceModel {
  final bool isValid;
  final String? errorMessage;
  final String? invoiceNumber;
  final CarServiceBreakdown breakdown;

  CarServiceInvoiceModel({
    required this.isValid,
    this.errorMessage,
    this.invoiceNumber,
    required this.breakdown,
  });

  factory CarServiceInvoiceModel.fromJson(Map<String, dynamic> json) {
    return CarServiceInvoiceModel(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      invoiceNumber: json['invoiceNumber'],
      breakdown: CarServiceBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}
