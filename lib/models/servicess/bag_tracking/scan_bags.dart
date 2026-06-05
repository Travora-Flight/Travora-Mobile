class ScanBagResponse {
  final bool found;
  final ScannedBagInfo? bag;
  final int totalScanned;
  final int totalRequired;
  final String? errorMessage;

  ScanBagResponse({
    required this.found,
    this.bag,
    required this.totalScanned,
    required this.totalRequired,
    this.errorMessage,
  });

  factory ScanBagResponse.fromJson(Map<String, dynamic> json) {
    return ScanBagResponse(
      found: json['found'] ?? false,
      bag: json['bag'] != null ? ScannedBagInfo.fromJson(json['bag']) : null,
      totalScanned: json['totalScanned'] ?? 0,
      totalRequired: json['totalRequired'] ?? 0,
      errorMessage: json['errorMessage'],
    );
  }
}

class ScannedBagInfo {
  final String tagNumber;
  final double? weightKg;
  final String? destination;
  final String? scannedAt;

  ScannedBagInfo({
    required this.tagNumber,
    this.weightKg,
    this.destination,
    this.scannedAt,
  });

  factory ScannedBagInfo.fromJson(Map<String, dynamic> json) {
    return ScannedBagInfo(
      tagNumber: json['tagNumber'] ?? '',
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      destination: json['destination'],
      scannedAt: json['scannedAt'],
    );
  }
}

// ----------------------------------------

class UploadBagPhotosResponse {
  final String tagNumber;
  final List<String> photos;
  final BagDetails? bag;
  final bool saved;
  final String? errorMessage;

  UploadBagPhotosResponse({
    required this.tagNumber,
    required this.photos,
    this.bag,
    required this.saved,
    this.errorMessage,
  });

  factory UploadBagPhotosResponse.fromJson(Map<String, dynamic> json) {
    return UploadBagPhotosResponse(
      tagNumber: json['tagNumber'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      bag: json['bag'] != null ? BagDetails.fromJson(json['bag']) : null,
      saved: json['saved'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}

class BagDetails {
  final String tagNumber;
  final double weightKg;
  final String destination;
  final String scannedAt;

  BagDetails({
    required this.tagNumber,
    required this.weightKg,
    required this.destination,
    required this.scannedAt,
  });

  factory BagDetails.fromJson(Map<String, dynamic> json) {
    return BagDetails(
      tagNumber: json['tagNumber'] ?? '',
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      destination: json['destination'] ?? '',
      scannedAt: json['scannedAt'] ?? '',
    );
  }
}
