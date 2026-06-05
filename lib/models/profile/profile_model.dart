class ProfileModel {
  final int customerId;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String email;
  final String? accountStatus;

  ProfileModel({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.email,
    this.accountStatus,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      customerId: json['customerId'] is int
          ? json['customerId']
          : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      email: json['email']?.toString() ?? '',
      accountStatus: json['accountStatus']?.toString(),
    );
  }
}
