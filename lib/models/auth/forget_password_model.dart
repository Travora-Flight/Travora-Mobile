class ForgetPasswordRequest {
  final String email;

  ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
    };
  }
}

class ForgetPasswordResponse {
  final bool success; 
  final String message;

  ForgetPasswordResponse({required this.success, required this.message});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
