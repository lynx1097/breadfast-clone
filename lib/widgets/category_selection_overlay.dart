import 'package:flutter/material.dart';
import 'package:breadfast/models/category_model.dart';
import 'package:breadfast/services/database_service.dart';
import 'package:breadfast/widgets/app_image.dart';

class CategorySelectionOverlay extends StatefulWidget {
  final Function(CategoryModel) onCategorySelected;
  final String? currentCategoryId;

  const CategorySelectionOverlay({
    super.key,
    required this.onCategorySelected,
    this.currentCategoryId,
  });

  @override
  State<CategorySelectionOverlay> createState() => _CategorySelectionOverlayState();
}

class _CategorySelectionOverlayState extends State<CategorySelectionOverlay> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _dbService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85, // Cover 85% of the screen from the bottom
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            title: const Text(
              'Select Category',
              style: TextStyle(color: Colors.black87, fontFamily: 'Faro', fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.purple.shade600, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading categories: ${snapshot.error}', style: const TextStyle(fontFamily: 'Faro')));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories available.', style: TextStyle(fontFamily: 'Faro')));
              }

              final categories = snapshot.data!;
              // Similar to HomeScreen's "Explore Breadfast" section
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1 / 1.25, // Adjusted for slightly more height
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final bool isSelected = category.id == widget.currentCategoryId;
                  return InkWell(
                    onTap: () {
                      widget.onCategorySelected(category);
                      // Navigator.of(context).pop(); // Pop after selection is handled by parent
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isSelected ? Colors.purple : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: !isSelected ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ] : [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: AppImage(url: category.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12, // Slightly smaller for overlay
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.purple : Colors.black87,
                                fontFamily: 'Faro',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper to show the overlay
void showCategorySelectionOverlay(BuildContext context, String? currentCategoryId, Function(CategoryModel) onCategorySelected) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Important for custom height and rounded corners
    builder: (BuildContext builderContext) {
      return CategorySelectionOverlay(
        onCategorySelected: onCategorySelected,
        currentCategoryId: currentCategoryId,
      );
    },
  );
} 