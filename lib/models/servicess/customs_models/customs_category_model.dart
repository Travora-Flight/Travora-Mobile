class CustomsCategoryModel {
  final int categoryId;
  final String name;

  CustomsCategoryModel({
    required this.categoryId,
    required this.name,
  });

  factory CustomsCategoryModel.fromJson(Map<String, dynamic> json) {
    return CustomsCategoryModel(
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
    };
  }
}
