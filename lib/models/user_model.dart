class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final List<String> roles;
  final String status;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.roles,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'roles': roles,
      'status': status,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    List<String>? roles,
    String? status,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
