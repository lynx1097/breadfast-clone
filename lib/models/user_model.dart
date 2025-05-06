class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  // Add other fields like defaultAddressId, createdAt, updatedAt as needed
  // String? hashedPassword; // For storing hashed password

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    // this.hashedPassword,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid, // map['uid'] usually the key, passed separately
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      // hashedPassword: map['hashedPassword'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      // 'hashedPassword': hashedPassword,
      // Add other fields for storage like createdAt, updatedAt
      // 'createdAt': FieldValue.serverTimestamp(), // Example for Firestore
    };
  }
} 