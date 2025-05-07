import 'dart:async';
import 'package:flutter/material.dart';
import 'package:breadfast/services/database_service.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/widgets/product_card.dart';
import 'package:breadfast/widgets/product_details_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final DatabaseService _dbService = DatabaseService();

  List<Product> _searchResults = [];
  bool _isLoading = false;
  bool _isFocused = false;
  String _currentQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchChanged() {
    if (_currentQuery == _searchController.text) return;
    _currentQuery = _searchController.text;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_currentQuery.isNotEmpty) {
        _performSearch(_currentQuery);
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await _dbService.searchProducts(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error searching products: $e');
      // Optionally show an error message to the user
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
      _currentQuery = '';
      _isLoading = false; 
    });
  }
  
  // Placeholder for favorite toggle, adapt as needed from HomeScreen
  void _toggleFavoriteStatus(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
      // Here you might want to update the product in your _searchResults list
      // and potentially persist this change to Firebase if this screen manages favorites.
      // For now, it only toggles the local state of the product in the list.
      final index = _searchResults.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _searchResults[index] = product; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 24), // Increased padding for search bar
        child: Padding(
          // Use SafeArea to avoid system intrusions like notch/status bar
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8.0, // Add top system padding
            left: 16.0, 
            right: 16.0, 
            bottom: 8.0
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: false, // Don't autofocus initially, let user tap
                  decoration: InputDecoration(
                    hintText: 'What are you looking for?',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontFamily: 'Faro'),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.purple, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0), 
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(fontFamily: 'Faro', fontSize: 15, color: Colors.black87),
                ),
              ),
              if (_isFocused || _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: InkWell(
                    onTap: _onCancelSearch,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.purple,
                        fontFamily: 'Faro',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchController.text.isEmpty && _searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Find your favorite products.',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Faro'),
        ),
      );
    }
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Text(
          'No products found for "${_searchController.text}"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Faro'),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Display 2 cards per row
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 150 / 220, // Adjust based on ProductCard dimensions width/height
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ProductCard(
          product: product,
          onFavoriteToggle: () => _toggleFavoriteStatus(product),
          onTap: () => showProductDetailsSheet(context, product),
        );
      },
    );
  }
} 