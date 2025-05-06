class Product {
  final String id;
  final String name;
  final String? manufacturer;
  final String? itemDescription;
  final double price; // Corresponds to currentPrice
  final double? oldPrice;
  final bool isDiscounted;
  final int? inventoryCount;
  final String imageUrl;
  final String? categoryId;
  final String? subCategoryId;
  final String? unit;
  final bool showPointsMultiplier;
  final Map<String, bool>? tags;
  final Map<String, String>? nutritionInfo;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;
  bool isFavorite; // Locally managed for now, will sync with Firebase later

  Product({
    required this.id,
    required this.name,
    this.manufacturer,
    this.itemDescription,
    required this.price,
    this.oldPrice,
    this.isDiscounted = false,
    this.inventoryCount,
    required this.imageUrl,
    this.categoryId,
    this.subCategoryId,
    this.unit,
    this.showPointsMultiplier = false,
    this.tags,
    this.nutritionInfo,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.isFavorite = false, // Default to not favorite
  });

  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String?,
      itemDescription: json['itemDescription'] as String?,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      isDiscounted: json['isDiscounted'] as bool? ?? false,
      inventoryCount: json['inventoryCount'] as int?,
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String?,
      subCategoryId: json['subCategoryId'] as String?,
      unit: json['unit'] as String?,
      showPointsMultiplier: json['showPointsMultiplier'] as bool? ?? false,
      tags: json['tags'] != null ? Map<String, bool>.from(json['tags']) : null,
      nutritionInfo: json['nutritionInfo'] != null ? Map<String, String>.from(json['nutritionInfo']) : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isActive: json['isActive'] as bool?,
      // isFavorite will be handled separately, not directly from product node in Firebase initially
    );
  }

  // For ProductCard compatibility
  String get productName => name;
  double get currentPrice => price;
} 