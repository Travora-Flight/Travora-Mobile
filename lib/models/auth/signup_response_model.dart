class SignUpResponseModel {
  final String? message;
  final String? sessionId;

  SignUpResponseModel({this.message, this.sessionId});

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      message: json['message'] ?? json['Message'] ?? "",
      sessionId: json['data'] != null
          ? json['data']['sessionId']?.toString()
          : json['sessionId']?.toString(),
    );
  }
}
