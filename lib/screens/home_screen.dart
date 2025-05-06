import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:breadfast/services/cart_service.dart'; // Import CartService
import 'top_picks_screen.dart'; // Import the new screen
import 'package:breadfast/widgets/product_card.dart'; // Import new ProductCard
import 'package:breadfast/models/banner_item_model.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/models/spotlight_item_model.dart';
import 'package:breadfast/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<BannerItem>> _bannersFuture;
  late Future<List<SpotlightItem>> _spotlightItemsFuture;
  late Future<List<Product>> _topPicksFuture;

  // Placeholder data for Explore Breadfast categories
  final List<Map<String, dynamic>> exploreCategoriesData = List.generate(
    27, // 3 columns * 9 rows
    (index) => {
      'title': 'Category ${index + 1}',
      'color': Colors.primaries[index % Colors.primaries.length].withOpacity(0.1), // Cycle through primary colors with opacity
      'icon': Icons.category_outlined, // Placeholder icon
    }
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _bannersFuture = _dbService.getBanners();
    _spotlightItemsFuture = _dbService.getSpotlightItems();
    _topPicksFuture = _dbService.getProducts(limit: 10); // Fetch 10 products for "Top picks"
  }

  // Function to handle favorite toggle (will need adjustment for Firebase later)
  void _toggleFavoriteStatus(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
      // If _topPicksFuture has completed, we might need to refresh the list
      // or find a way to update the specific product in the displayed list.
      // For now, this only changes the model state. A more robust update
      // would involve re-fetching or updating the state that FutureBuilder uses.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // As per screenshot
        elevation: 0, // No shadow
        title: InkWell(
          onTap: () {
            // TODO: Implement address selection overlay
            print('Home title tapped');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min, // To make InkWell only as large as the Row
            children: [
              Text(
                'Home',
                style: TextStyle(
                  color: Colors.purple, // Same as active navbar item
                  fontWeight: FontWeight.normal, // Regular weight
                  fontSize: 16, // Adjust for smaller size
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.purple, // Same as active navbar item
                size: 20, // Adjust for smaller size
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.purple), // Placeholder color
            onPressed: () { /* TODO: Navigate to chat screen */ },
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.purple), // Placeholder color
            onPressed: () { /* TODO: Navigate to referrals screen */ },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 16), // Some padding at the top

          // --- Carousel Banner Section ---
          FutureBuilder<List<BannerItem>>(
            future: _bannersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200.0, // Same height as CarouselOptions
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 200.0,
                  child: Center(child: Text('Error loading banners: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 200.0,
                  child: Center(child: Text('No banners available')),
                );
              } else {
                final banners = snapshot.data!;
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    aspectRatio: 16/9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: banners.length > 1, // Disable if only one banner
                    reverse: false,
                    autoPlay: banners.length > 1, // Disable if only one banner
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.2,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: banners.map((banner) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                           decoration: BoxDecoration( // Added for visual consistency
                            color: Colors.grey.shade200, // Placeholder background
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // child: item, // OLD: item was a PlaceholderBannerItem
                          child: ClipRRect( // Ensure image respects border radius
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network( // Using Image.network
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              // Optional: Add errorBuilder and loadingBuilder for Image.network
                              errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              }
            },
          ),
          // --- End of Carousel Banner Section ---

          // --- The Spotlight Section --- 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'The spotlight',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          FutureBuilder<List<SpotlightItem>>(
            future: _spotlightItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120, // Same height as before
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 120,
                  child: Center(child: Text('Error loading spotlight: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: Text('No spotlight items available')),
                );
              } else {
                final spotlightItems = snapshot.data!;
                return SizedBox(
                  height: 120, // Height for the horizontal list items
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: spotlightItems.length,
                    itemBuilder: (context, index) {
                      final item = spotlightItems[index];
                      // Using SpotlightCardItem (assuming it's defined elsewhere and takes these params)
                      // If SpotlightCardItem needs refactoring to take SpotlightItem model, that's a later step.
                      // For now, creating a placeholder display:
                      return SpotlightCardItem(
                        title: item.title,
                        imageUrl: item.imageUrl,
                      );
                    },
                  ),
                );
              }
            },
          ),
          // --- End of The Spotlight Section ---

          // --- Top picks for you Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top picks for you',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // Faro-BoldLucky
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TopPicksScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Faro-SemiBoldLucky
                          color: Colors.purple, // Active color
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.purple,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260, 
            child: FutureBuilder<List<Product>>(
              future: _topPicksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product, // Pass the whole product object
                        onFavoriteToggle: () => _toggleFavoriteStatus(product),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // --- End of Top picks for you Section ---

          // --- Explore Breadfast Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              'Explore Breadfast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding around the grid
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exploreCategoriesData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1 / 1.2, // Width / Height ratio (making them slightly taller)
              ),
              itemBuilder: (context, index) {
                final category = exploreCategoriesData[index];
                return CategoryCardItem(
                  title: category['title'] as String,
                  color: category['color'] as Color,
                  icon: category['icon'] as IconData,
                );
              },
            ),
          ),
          const SizedBox(height: 24), // Padding at the bottom of the list
          // --- End of Explore Breadfast Section ---
        ],
      ),
    );
  }
}

// Simple placeholder widget for banner items
class PlaceholderBannerItem extends StatelessWidget {
  final Color color;
  final String text;
  const PlaceholderBannerItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration( // Added decoration for rounded corners
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// Widget for Spotlight card items
class SpotlightCardItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color? color; // Optional fallback color
  // final String text; // text is effectively replaced by title

  const SpotlightCardItem({
    super.key,
    required this.title,
    required this.imageUrl,
    this.color, // No longer required, can be used as fallback
    // required this.text, // Removed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270, // Width of the spotlight card
      margin: const EdgeInsets.only(right: 10.0), // Spacing between cards
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners for spotlight cards
        child: Stack(
          fit: StackFit.expand, // Make Stack fill the Container
          children: [
            // Background Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              color: color ?? Colors.grey.shade200, // Use provided color as overlay or fallback background
              colorBlendMode: BlendMode.multiply, // Example, adjust as needed or remove if color is just for fallback
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: color ?? Colors.grey.shade300, // Fallback color if image fails
                  child: Center(
                    child: Icon(Icons.broken_image, color: Colors.grey.shade600, size: 40),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: color ?? Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            // Dark overlay for better text visibility (optional)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0]
                ),
              ),
            ),
            // Title Text
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding for the title
                child: Text(
                  title, // Use the title property
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for Category Card items
class CategoryCardItem extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const CategoryCardItem({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color, // Background color from data
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to the start (top)
          crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, // Smaller font for category title
                fontWeight: FontWeight.w600, // Semibold
                color: Colors.black87, // Darker text for better readability on light backgrounds
              ),
              maxLines: 2, // Allow for two lines for longer titles
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(), // Pushes icon towards the center/bottom depending on available space
            Icon(
              icon,
              size: 40, // Adjust icon size as needed
              color: Colors.black54, // Icon color
            ),
            const Spacer(), // Provides some space if needed, or helps center icon if only one spacer is used before it
          ],
        ),
      ),
    );
  }
} 