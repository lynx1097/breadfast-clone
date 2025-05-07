import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breadfast/models/category_model.dart';
import 'package:breadfast/models/sub_category_model.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/services/database_service.dart';
import 'package:breadfast/services/cart_service.dart';
import 'package:breadfast/widgets/product_card.dart';
import 'package:breadfast/widgets/product_details_sheet.dart';
import 'package:breadfast/screens/cart_screen.dart';
import 'package:breadfast/widgets/category_selection_overlay.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, List<Product>> _productsBySubCategory = {};
  List<SubCategoryModel> _subCategories = [];
  bool _isLoading = true;
  String? _selectedSubCategoryId;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();
  Map<String, GlobalKey> _subCategoryKeys = {};
  List<GlobalKey> _filterChipKeys = [];
  late CategoryModel _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
    _fetchCategoryData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategoryData({CategoryModel? newCategory}) async {
    if (newCategory != null) {
      _currentCategory = newCategory;
      _selectedSubCategoryId = null;
    }
    setState(() {
      _isLoading = true;
      _productsBySubCategory = {};
      _subCategories = [];
      _subCategoryKeys = {};
      _filterChipKeys = [];
    });

    try {
      final subCategories = await _dbService.getSubCategories(_currentCategory.id);
      _subCategories = subCategories;
      if (_subCategories.isNotEmpty) {
        if (_selectedSubCategoryId == null || !_subCategories.any((sc) => sc.id == _selectedSubCategoryId)) {
            _selectedSubCategoryId = _subCategories.first.id;
        }
        _filterChipKeys = List.generate(_subCategories.length, (_) => GlobalKey());
        for (var subCat in _subCategories) {
          _subCategoryKeys[subCat.id] = GlobalKey();
        }
      }

      Map<String, List<Product>> productsMap = {};
      for (var subCategory in _subCategories) {
        final products = await _dbService.getProductsBySubCategory(subCategory.id);
        productsMap[subCategory.id] = products;
      }
      _productsBySubCategory = productsMap;
    } catch (e) {
      print('Error fetching category data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      if(_selectedSubCategoryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFilterChipIsVisible(_selectedSubCategoryId!));
      }
    }
  }
  
  void _onCategorySelectedFromOverlay(CategoryModel selectedCategory) {
    Navigator.of(context).pop();
    if (selectedCategory.id != _currentCategory.id) {
      _fetchCategoryData(newCategory: selectedCategory);
    }
  }

  void _toggleFavoriteStatus(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  void _scrollToSubCategoryContent(String subCategoryId) {
    final key = _subCategoryKeys[subCategoryId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0,
      );
    }
  }

  void _ensureFilterChipIsVisible(String subCategoryId) {
    final int chipIndex = _subCategories.indexWhere((sc) => sc.id == subCategoryId);
    if (chipIndex != -1 && chipIndex < _filterChipKeys.length) {
      final chipKey = _filterChipKeys[chipIndex];
      if (chipKey.currentContext != null) {
        Scrollable.ensureVisible(
          chipKey.currentContext!,
          duration: const Duration(milliseconds:300),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
      }
    }
  }

  void _handleSubCategoryFilterTap(String subCategoryId) {
    setState(() {
      _selectedSubCategoryId = subCategoryId;
    });
    _scrollToSubCategoryContent(subCategoryId);
    _ensureFilterChipIsVisible(subCategoryId);
  }

  Widget _buildCartIconWithBadge(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    int itemCount = cartService.totalIndividualItems;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined, color: Colors.purple, size: 28),
        if (itemCount > 0)
          Positioned(
            right: -5, top: -5,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(child: Text('$itemCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
         leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () {
            showCategorySelectionOverlay(
              context,
              _currentCategory.id,
              _onCategorySelectedFromOverlay,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentCategory.name,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Faro'),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.purple.shade400, size: 20),
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Consumer<CartService>(builder: (context, cart, child) => _buildCartIconWithBadge(context)),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CartScreen())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subCategories.isEmpty
              ? const Center(child: Text('No sub-categories found.', style: TextStyle(fontFamily: 'Faro', fontSize: 14)))
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SubCategoryFilterDelegate(
                        subCategories: _subCategories,
                        selectedSubCategoryId: _selectedSubCategoryId,
                        onSelected: _handleSubCategoryFilterTap,
                        height: 48,
                        filterScrollController: _filterScrollController,
                        filterChipKeys: _filterChipKeys,
                      ),
                    ),
                    ..._subCategories.map((subCategory) {
                      final products = _productsBySubCategory[subCategory.id] ?? [];
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            key: _subCategoryKeys[subCategory.id],
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                            child: Text(
                              subCategory.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Faro', color: Colors.black87),
                            ),
                          ),
                          if (products.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                              child: Center(child: Text('No products in this sub-category.', style: TextStyle(fontFamily: 'Faro', fontSize: 13))),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 6.0,
                                  mainAxisSpacing: 6.0,
                                  childAspectRatio: 150 / 250,
                                ),
                                itemBuilder: (context, prodIndex) {
                                  final product = products[prodIndex];
                                  return ProductCard(
                                    product: product,
                                    onFavoriteToggle: () => _toggleFavoriteStatus(product),
                                    onTap: () => showProductDetailsSheet(context, product),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 10),
                        ]),
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}

class _SubCategoryFilterDelegate extends SliverPersistentHeaderDelegate {
  final List<SubCategoryModel> subCategories;
  final String? selectedSubCategoryId;
  final Function(String) onSelected;
  final double height;
  final ScrollController filterScrollController;
  final List<GlobalKey> filterChipKeys;

  _SubCategoryFilterDelegate({
    required this.subCategories,
    required this.selectedSubCategoryId,
    required this.onSelected,
    this.height = 48.0,
    required this.filterScrollController,
    required this.filterChipKeys,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListView.builder(
        controller: filterScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          bool isSelected = selectedSubCategoryId == subCategory.id;
          return Padding(
            key: filterChipKeys[index],
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: FilterChip(
              label: Text(subCategory.name, style: TextStyle(fontFamily: 'Faro', color: isSelected ? Colors.white : Colors.purple.shade700, fontWeight: FontWeight.w500, fontSize: 12)),
              selected: isSelected,
              onSelected: (bool selected) {
                onSelected(subCategory.id);
              },
              backgroundColor: Colors.purple.withOpacity(0.05),
              selectedColor: Colors.purple.shade500,
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.purple.shade100, width: isSelected ? 0 : 0.8)),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SubCategoryFilterDelegate oldDelegate) {
    return oldDelegate.subCategories != subCategories ||
           oldDelegate.selectedSubCategoryId != selectedSubCategoryId ||
           oldDelegate.height != height ||
           oldDelegate.filterScrollController != filterScrollController ||
           oldDelegate.filterChipKeys != filterChipKeys;
  }
} 