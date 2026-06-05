
class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        "email": email,
        "otp": otp,
      };
}

class VerifyOtpResponse {
  final bool success;
  final String? resetToken; 
  final String message; 

  VerifyOtpResponse(
      {required this.success, this.resetToken, required this.message});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      resetToken: json['resetToken'],
      message: json['message'] ?? '',
    );
  }
}
