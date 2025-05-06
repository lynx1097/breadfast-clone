class SpotlightItem {
  final String id;
  final String title;
  final String imageUrl;
  final String actionType;
  final String actionValue;
  final int sortOrder;
  final bool isActive;

  SpotlightItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.actionType,
    required this.actionValue,
    required this.sortOrder,
    this.isActive = true,
  });

  factory SpotlightItem.fromJson(String id, Map<String, dynamic> json) {
    return SpotlightItem(
      id: id,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      actionType: json['actionType'] as String,
      actionValue: json['actionValue'] as String,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
} 