class SubCategoryModel {
  final String id;
  final String name;
  final String categoryId; // To link back to the main category
  final int sortOrder; // For ordering sub-categories in the filter bar

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.sortOrder,
  });

  factory SubCategoryModel.fromJson(String id, Map<String, dynamic> json) {
    return SubCategoryModel(
      id: id,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0, // Default sortOrder to 0 if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
    };
  }
} 