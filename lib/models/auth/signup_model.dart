class SignUpRequestModel {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? password;
  String? confirmPassword;

  String? sessionId;
  String? passportNumber;
  String? expiryDate;

  SignUpRequestModel({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.confirmPassword,
    this.sessionId,
    this.passportNumber,
    this.expiryDate,
  });

  Map<String, dynamic> toStep1Json() {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "PhoneNumber": mobile,
      "Password": password,
      "ConfirmPassword": confirmPassword,
    };
  }

  Map<String, dynamic> toStep2Json() {
    return {
      "SessionId": sessionId,
      "PassportNumber": passportNumber,
      "PassportExpiryDate": expiryDate,
    };
  }
}
