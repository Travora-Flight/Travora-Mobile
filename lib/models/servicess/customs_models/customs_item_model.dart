class CustomsItemModel {
  final bool success;
  final AddedItem? addedItem;
  final double totalDeclaredValue;
  final double totalCustomsFee;
  final String? errorMessage;

  CustomsItemModel({
    required this.success,
    this.addedItem,
    required this.totalDeclaredValue,
    required this.totalCustomsFee,
    this.errorMessage,
  });

  factory CustomsItemModel.fromJson(Map<String, dynamic> json) {
    return CustomsItemModel(
      success: json['success'] ?? false,
      addedItem: json['addedItem'] != null
          ? AddedItem.fromJson(json['addedItem'])
          : null,
      totalDeclaredValue: (json['totalDeclaredValue'] ?? 0).toDouble(),
      totalCustomsFee: (json['totalCustomsFee'] ?? 0).toDouble(),
      errorMessage: json['errorMessage'],
    );
  }
}

class AddedItem {
  final String itemDescription;
  final String itemType;
  final double declaredValue;
  final int quantity;
  final double customsRatePercentage;
  final String? purchaseInvoiceUrl;
  final double totalValue;
  final double totalCustomsValue;

  AddedItem({
    required this.itemDescription,
    required this.itemType,
    required this.declaredValue,
    required this.quantity,
    required this.customsRatePercentage,
    this.purchaseInvoiceUrl,
    required this.totalValue,
    required this.totalCustomsValue,
  });

  factory AddedItem.fromJson(Map<String, dynamic> json) {
    return AddedItem(
      itemDescription: json['itemDescription'] ?? '',
      itemType: json['itemType'] ?? '',
      declaredValue: (json['declaredValue'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      customsRatePercentage: (json['customsRatePercentage'] ?? 0).toDouble(),
      purchaseInvoiceUrl: json['purchaseInvoiceUrl'],
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      totalCustomsValue: (json['totalCustomsValue'] ?? 0).toDouble(),
    );
  }
}
