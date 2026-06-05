class ValidateCompanionResponse {
  final bool isValid;
  final CompanionInfo? companion;
  final int? totalCompanions;
  final String? errorMessage;

  ValidateCompanionResponse({
    required this.isValid,
    this.companion,
    this.totalCompanions,
    this.errorMessage,
  });

  factory ValidateCompanionResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCompanionResponse(
      isValid: json['isValid'] ?? false,
      companion: json['companion'] != null
          ? CompanionInfo.fromJson(json['companion'])
          : null,
      totalCompanions: json['totalCompanions'],
      errorMessage: json['errorMessage'],
    );
  }
}


class CompanionInfo {
  final String? firstName;
  final String? lastName;
  final String? seatNumber;
  final String? travelClass;
  final String? passportNumber;
  final String? passportImageUrl;
  final String? nationality;
  final String? dateOfBirth;
  final String? passportExpiryDate;

  CompanionInfo({
    this.firstName,
    this.lastName,
    this.seatNumber,
    this.travelClass,
    this.passportNumber,
    this.passportImageUrl,
    this.nationality,
    this.dateOfBirth,
    this.passportExpiryDate,
  });

  factory CompanionInfo.fromJson(Map<String, dynamic> json) {
    return CompanionInfo(
      firstName: json['firstName'],
      lastName: json['lastName'],
      seatNumber: json['seatNumber'],
      travelClass: json['travelClass'],
      passportNumber: json['passportNumber'],
      passportImageUrl: json['passportImageUrl'],
      nationality: json['nationality'],
      dateOfBirth: json['dateOfBirth'],
      passportExpiryDate: json['passportExpiryDate'],
    );
  }
}
