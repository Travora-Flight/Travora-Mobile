
class BagTrackingBaggageDetails {
  final int includedBags;
  final int totalBags;
  final int extraBags;
  final double extraBaggageFee;

  BagTrackingBaggageDetails({
    required this.includedBags,
    required this.totalBags,
    required this.extraBags,
    required this.extraBaggageFee,
  });

  factory BagTrackingBaggageDetails.fromJson(Map<String, dynamic> json) {
    return BagTrackingBaggageDetails(
      includedBags: json['includedBags'] ?? 0,
      totalBags: json['totalBags'] ?? 0,
      extraBags: json['extraBags'] ?? 0,
      extraBaggageFee: (json['extraBaggageFee'] ?? 0).toDouble(),
    );
  }
}

class BagTrackingBreakdown {
  final double packageValue;
  final BagTrackingBaggageDetails baggageDetails;
  final double customsValue;
  final double customsFee;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double totalAmount;

  BagTrackingBreakdown({
    required this.packageValue,
    required this.baggageDetails,
    required this.customsValue,
    required this.customsFee,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.totalAmount,
  });

  factory BagTrackingBreakdown.fromJson(Map<String, dynamic> json) {
    return BagTrackingBreakdown(
      packageValue: (json['packageValue'] ?? 0).toDouble(),
      baggageDetails:
          BagTrackingBaggageDetails.fromJson(json['baggageDetails'] ?? {}),
      customsValue: (json['customsValue'] ?? 0).toDouble(),
      customsFee: (json['customsFee'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class BagTrackingInvoiceModel {
  final bool isValid;
  final String? errorMessage;
  final String? invoiceNumber;
  final BagTrackingBreakdown breakdown;

  BagTrackingInvoiceModel({
    required this.isValid,
    this.errorMessage,
    this.invoiceNumber,
    required this.breakdown,
  });

  factory BagTrackingInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BagTrackingInvoiceModel(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      invoiceNumber: json['invoiceNumber'],
      breakdown: BagTrackingBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}
