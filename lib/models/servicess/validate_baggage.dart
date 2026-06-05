class BaggageBreakdown {
  final String? ticketNumber;
  final int? baggageCount;

  BaggageBreakdown({this.ticketNumber, this.baggageCount});

  factory BaggageBreakdown.fromJson(Map<String, dynamic> json) {
    return BaggageBreakdown(
      ticketNumber: json['ticketNumber'],
      baggageCount: json['baggageCount'],
    );
  }
}

class ValidateBaggageRequest {
  Map<String, dynamic> toJson() => {};
}

class ValidateBaggageResponse {
  final bool isValid;
  final int? expected;
  final int? actual;
  final int? totalBaggageCount;
  final List<BaggageBreakdown>? breakdown;
  final String? errorCode;
  final String? errorMessage;

  ValidateBaggageResponse({
    required this.isValid,
    this.expected,
    this.actual,
    this.totalBaggageCount,
    this.breakdown,
    this.errorCode,
    this.errorMessage,
  });

  factory ValidateBaggageResponse.fromJson(Map<String, dynamic> json) {
    return ValidateBaggageResponse(
      isValid: json['isValid'] ?? false,
      expected: json['expected'],
      actual: json['actual'],
      totalBaggageCount: json['totalBaggageCount'],
      breakdown: (json['breakdown'] as List<dynamic>?)
          ?.map((e) => BaggageBreakdown.fromJson(e))
          .toList(),
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
    );
  }
}
