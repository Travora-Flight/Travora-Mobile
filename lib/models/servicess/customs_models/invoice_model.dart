class InvoiceModel {
  final bool isValid;
  final String? errorMessage;
  final String invoiceNumber;
  final InvoiceBreakdown breakdown;

  InvoiceModel({
    required this.isValid,
    this.errorMessage,
    required this.invoiceNumber,
    required this.breakdown,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      breakdown: InvoiceBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}

class InvoiceBreakdown {
  final double packageValue;
  final BaggageDetails baggageDetails;
  final CompanionDetails companionDetails;
  final double customsValue;
  final double customsFee;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double totalAmount;

  InvoiceBreakdown({
    required this.packageValue,
    required this.baggageDetails,
    required this.companionDetails,
    required this.customsValue,
    required this.customsFee,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.totalAmount,
  });

  factory InvoiceBreakdown.fromJson(Map<String, dynamic> json) {
    return InvoiceBreakdown(
      packageValue: (json['packageValue'] ?? 0).toDouble(),
      baggageDetails: BaggageDetails.fromJson(json['baggageDetails'] ?? {}),
      companionDetails:
          CompanionDetails.fromJson(json['companionDetails'] ?? {}),
      customsValue: (json['customsValue'] ?? 0).toDouble(),
      customsFee: (json['customsFee'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class BaggageDetails {
  final int includedBags;
  final int totalBags;
  final int extraBags;
  final double extraBaggageFee;

  BaggageDetails({
    required this.includedBags,
    required this.totalBags,
    required this.extraBags,
    required this.extraBaggageFee,
  });

  factory BaggageDetails.fromJson(Map<String, dynamic> json) {
    return BaggageDetails(
      includedBags: json['includedBags'] ?? 0,
      totalBags: json['totalBags'] ?? 0,
      extraBags: json['extraBags'] ?? 0,
      extraBaggageFee: (json['extraBaggageFee'] ?? 0).toDouble(),
    );
  }
}

class CompanionDetails {
  final int includedCompanions;
  final int totalCompanions;
  final int extraCompanions;
  final double extraCompanionsFee;

  CompanionDetails({
    required this.includedCompanions,
    required this.totalCompanions,
    required this.extraCompanions,
    required this.extraCompanionsFee,
  });

  factory CompanionDetails.fromJson(Map<String, dynamic> json) {
    return CompanionDetails(
      includedCompanions: json['includedCompanions'] ?? 0,
      totalCompanions: json['totalCompanions'] ?? 0,
      extraCompanions: json['extraCompanions'] ?? 0,
      extraCompanionsFee: (json['extraCompanionsFee'] ?? 0).toDouble(),
    );
  }
}
