class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'CurrentPassword': currentPassword,
      'NewPassword': newPassword,
      'ConfirmPassword': confirmPassword,
    };
  }
}
