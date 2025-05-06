import 'package:firebase_database/firebase_database.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/models/banner_item_model.dart';
import 'package:breadfast/models/spotlight_item_model.dart';
import 'package:breadfast/models/user_model.dart';
// Import Category model if you plan to add category fetching methods soon
// import 'package:breadfast/models/category_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Fetch all products (or a limited number for home screen)
  Future<List<Product>> getProducts({int? limit}) async {
    Query query = _db.ref('products').orderByChild('isActive').equalTo(true);
    if (limit != null) {
      query = query.limitToFirst(limit);
    }
    final snapshot = await query.get();
    if (snapshot.exists && snapshot.value != null) {
      final Map<String, dynamic> productsMap = Map<String, dynamic>.from(snapshot.value as Map);
      List<Product> products = [];
      productsMap.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value as Map);
        // Optionally filter by isActive again if not handled by query effectively for all cases
        if (productData['isActive'] == true) {
          products.add(Product.fromJson(key, productData));
        }
      });
      // Optionally sort products if needed, e.g., by name or a specific order field
      // products.sort((a, b) => a.name.compareTo(b.name)); 
      return products;
    }
    return [];
  }

  // Fetch active banners, sorted by sortOrder
  Future<List<BannerItem>> getBanners() async {
    final snapshot = await _db.ref('banners')
                              .orderByChild('sortOrder')
                              .get();
    if (snapshot.exists && snapshot.value != null) {
      final Map<String, dynamic> bannersMap = Map<String, dynamic>.from(snapshot.value as Map);
      List<BannerItem> banners = [];
      bannersMap.forEach((key, value) {
        final bannerData = Map<String, dynamic>.from(value as Map);
        if (bannerData['isActive'] == true) { // Double check isActive
          banners.add(BannerItem.fromJson(key, bannerData));
        }
      });
      // Banners are already ordered by sortOrder from Firebase query if keys are standard
      // If keys are not ordered (e.g. push IDs), then sort explicitly after fetching:
      // banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return banners;
    }
    return [];
  }

  // Fetch active spotlight items, sorted by sortOrder
  Future<List<SpotlightItem>> getSpotlightItems() async {
    final snapshot = await _db.ref('spotlightItems')
                               .orderByChild('sortOrder')
                               .get();
    if (snapshot.exists && snapshot.value != null) {
      final Map<String, dynamic> spotlightMap = Map<String, dynamic>.from(snapshot.value as Map);
      List<SpotlightItem> items = [];
      spotlightMap.forEach((key, value) {
        final itemData = Map<String, dynamic>.from(value as Map);
        if (itemData['isActive'] == true) { // Double check isActive
          items.add(SpotlightItem.fromJson(key, itemData));
        }
      });
      // items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder)); // Ensure sorting if needed
      return items;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getUserByPhoneNumber(String rawPhoneNumber) async {
    if (rawPhoneNumber.length != 10 || !rawPhoneNumber.startsWith('1')) {
      // Basic validation, though PhoneAuthScreen already does this
      return null;
    }
    String formattedPhoneNumber = '+20$rawPhoneNumber'; // Assumes +20 prefix for Egypt

    try {
      final snapshot = await _db
          .ref('users')
          .orderByChild('phoneNumber')
          .equalTo(formattedPhoneNumber)
          .limitToFirst(1) // Expecting only one user per phone number
          .get();

      if (snapshot.exists && snapshot.value != null) {
        // Data is a Map<dynamic, dynamic> where key is user UID, value is user data
        final Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
        final String userId = usersMap.keys.first;
        final Map<String, dynamic> userData = Map<String, dynamic>.from(usersMap[userId] as Map);
        userData['uid'] = userId; // Add UID to the user data map
        return userData;
      }
      return null;
    } catch (e) {
      print('Error fetching user by phone number: $e');
      return null;
    }
  }

  // Placeholder for creating a user - will need password hashing etc.
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    // IMPORTANT: Password should be securely hashed here before saving to userData
    // For now, this is just a placeholder structure.
    // Example: userData['password'] = await hashPassword(userData['password']);
    try {
      await _db.ref('users/$uid').set(userData);
    } catch (e) {
      print('Error creating user: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // TODO: Add methods for fetching categories, subcategories, user-specific data, etc.
  // TODO: Add CRUD operations (Create, Read by ID, Update, Delete)
}

// Basic UserModel (can be in a separate file lib/models/user_model.dart later)
// class UserModel {
//   final String uid;
//   final String firstName;
//   final String lastName;
//   final String phoneNumber;
//   final String email;
//   // Add other fields like defaultAddressId, createdAt, updatedAt as needed
//   // String? hashedPassword; // For storing hashed password
//
//   UserModel({
//     required this.uid,
//     required this.firstName,
//     required this.lastName,
//     required this.phoneNumber,
//     required this.email,
//     // this.hashedPassword,
//   });
//
//   factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
//     return UserModel(
//       uid: uid, // map['uid'] usually the key, passed separately
//       firstName: map['firstName'] as String,
//       lastName: map['lastName'] as String,
//       phoneNumber: map['phoneNumber'] as String,
//       email: map['email'] as String,
//       // hashedPassword: map['hashedPassword'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName,
//       'phoneNumber': phoneNumber,
//       'email': email,
//       // 'hashedPassword': hashedPassword,
//       // Add other fields for storage
//     };
//   }
// } 