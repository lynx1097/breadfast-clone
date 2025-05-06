class BannerItem {
  final String id;
  final String imageUrl;
  final String actionType;
  final String actionValue;
  final String? title;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final String? startDate; // Consider parsing to DateTime if needed for logic
  final String? endDate;   // Consider parsing to DateTime if needed for logic

  BannerItem({
    required this.id,
    required this.imageUrl,
    required this.actionType,
    required this.actionValue,
    this.title,
    this.description,
    required this.sortOrder,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  factory BannerItem.fromJson(String id, Map<String, dynamic> json) {
    return BannerItem(
      id: id,
      imageUrl: json['imageUrl'] as String,
      actionType: json['actionType'] as String,
      actionValue: json['actionValue'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }
} 