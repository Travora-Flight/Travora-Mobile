class UpdateLocationModel {
  final String? locationType;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  UpdateLocationModel({
    this.locationType,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (locationType != null && locationType!.isNotEmpty) {
      data['locationType'] = locationType;
    }
    if (streetAddress != null && streetAddress!.isNotEmpty) {
      data['streetAddress'] = streetAddress;
    }
    if (city != null && city!.isNotEmpty) {
      data['city'] = city;
    }
    if (state != null && state!.isNotEmpty) {
      data['state'] = state;
    }
    if (country != null && country!.isNotEmpty) {
      data['country'] = country;
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      data['postalCode'] = postalCode;
    }

    return data;
  }
}
