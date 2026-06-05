class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        "resetToken": resetToken,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };
}

class ResetPasswordResponse {
  final bool success; 
  final String message;

  ResetPasswordResponse({required this.success, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
