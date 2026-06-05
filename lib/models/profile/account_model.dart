class AccountModel {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String? gender; 
  final String? dateOfBirth;
  final String? passportNumber;

  AccountModel({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.passportNumber,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      passportNumber: json['passportNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
    };
  }
}
