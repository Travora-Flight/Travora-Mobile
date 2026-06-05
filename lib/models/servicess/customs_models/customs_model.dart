class CustomsModel {
  final bool success;
  final String customsType;
  final String? message;
  final String? errorMessage;

  CustomsModel({
    required this.success,
    required this.customsType,
    this.message,
    this.errorMessage,
  });

  factory CustomsModel.fromJson(Map<String, dynamic> json) {
    return CustomsModel(
      success: json['success'] ?? false,
      customsType: json['customsType'] ?? '',
      message: json['message'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'customsType': customsType,
      'message': message,
      'errorMessage': errorMessage,
    };
  }
}
