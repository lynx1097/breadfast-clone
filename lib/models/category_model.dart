class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(String id, Map<String, dynamic> json) {
    return CategoryModel(
      id: id,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      sortOrder: json['sortOrder'] as int,
    );
  }
} 