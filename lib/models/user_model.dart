class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String? password; // Changed from hashedPassword
  final String? createdAt;
  final String? updatedAt;
  final String? defaultAddressId;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.password, // Changed
    this.createdAt,
    this.updatedAt,
    this.defaultAddressId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid, 
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String? ?? '', // Handle if email is null in DB
      password: map['password'] as String?, // Changed from hashedPassword
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      defaultAddressId: map['defaultAddressId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      if (password != null) 'password': password, // Changed from hashedPassword
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (defaultAddressId != null) 'defaultAddressId': defaultAddressId,
    };
  }
} 