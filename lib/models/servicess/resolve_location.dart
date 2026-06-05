class ResolveLocationModel {
  final bool isValid;
  final String? errorMessage;
  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? locationType;

  ResolveLocationModel({
    required this.isValid,
    this.errorMessage,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.locationType,
  });

  factory ResolveLocationModel.fromJson(Map<String, dynamic> json) {
    return ResolveLocationModel(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      formattedAddress: json['formattedAddress'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      locationType: json['locationType'],
    );
  }
}
