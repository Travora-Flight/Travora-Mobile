class LoginResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? role;
  final int? customerId;
  final String? firstName;
  final String? accountStatus;
  final String? message;

  LoginResponseModel({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.role,
    this.customerId,
    this.firstName,
    this.accountStatus,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['userData'] as Map<String, dynamic>?;

    return LoginResponseModel(
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      expiresIn: json['expiresIn'] as int?,
      role: json['role']?.toString(), 

      customerId: userData != null ? userData['customerId'] as int? : null,
      firstName: userData != null ? userData['firstName']?.toString() : null,
      accountStatus:
          userData != null ? userData['accountStatus']?.toString() : null,

      message: json['message']?.toString(),
    );
  }
}
