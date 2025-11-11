class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? authProvider; // 'local', 'google', etc.
  final List<String> roles; // Array of role names from token
  final UserProfile? profile; // Profile object with verificationStatus
  final bool isVerified; // Boolean from token
  final String status; // 'active', 'inactive', etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.authProvider,
    this.roles = const [],
    this.profile,
    this.isVerified = false,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });
  
  // Helper to check if user has a specific role
  bool hasRole(String roleName) {
    return roles.contains(roleName.toLowerCase());
  }
  
  // Helper to check verification level
  String get verificationStatus {
    return profile?.verificationStatus ?? 'none';
  }
  
  // Helper to check if can create posts
  bool get canCreatePosts {
    if (!isVerified) return false;
    final allowedStatuses = ['kyc', 'professional', 'full'];
    return allowedStatuses.contains(verificationStatus);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      authProvider: json['authProvider'],
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'authProvider': authProvider,
      'roles': roles,
      'profile': profile?.toJson(),
      'isVerified': isVerified,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? authProvider,
    List<String>? roles,
    UserProfile? profile,
    bool? isVerified,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      authProvider: authProvider ?? this.authProvider,
      roles: roles ?? this.roles,
      profile: profile ?? this.profile,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Profile class to match backend token structure
class UserProfile {
  final String? verificationStatus; // 'none', 'kyc', 'professional', 'full'
  final String? fullName;
  final String? bio;
  final String? profession;
  final String? photoUrl;
  final String? gender;
  final int? age;
  final String? religion;
  final String? ethnicity;
  final String? education;
  final List<String>? languages;
  final List<String>? interests;
  final double? ratingAvg;
  final int? ratingCount;

  UserProfile({
    this.verificationStatus,
    this.fullName,
    this.bio,
    this.profession,
    this.photoUrl,
    this.gender,
    this.age,
    this.religion,
    this.ethnicity,
    this.education,
    this.languages,
    this.interests,
    this.ratingAvg,
    this.ratingCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      verificationStatus: json['verificationStatus'],
      fullName: json['fullName'],
      bio: json['bio'],
      profession: json['profession'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      age: json['age'],
      religion: json['religion'],
      ethnicity: json['ethnicity'],
      education: json['education'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'] is String
              ? (json['languages'] as String).split(',')
              : json['languages'])
          : null,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'] is String
              ? (json['interests'] as String).split(',')
              : json['interests'])
          : null,
      ratingAvg: json['ratingAvg'] != null
          ? double.tryParse(json['ratingAvg'].toString())
          : null,
      ratingCount: json['ratingCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verificationStatus': verificationStatus,
      'fullName': fullName,
      'bio': bio,
      'profession': profession,
      'photoUrl': photoUrl,
      'gender': gender,
      'age': age,
      'religion': religion,
      'ethnicity': ethnicity,
      'education': education,
      'languages': languages,
      'interests': interests,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
    };
  }
}
