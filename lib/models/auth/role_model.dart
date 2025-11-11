class Role {
  final String id;
  final String name;
  final DateTime? createdAt;

  Role({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class UserRole {
  final String id;
  final String userId;
  final String roleId;
  final Role? role;
  final DateTime? createdAt;

  UserRole({
    required this.id,
    required this.userId,
    required this.roleId,
    this.role,
    this.createdAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      roleId: json['roleId'] ?? '',
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roleId': roleId,
      'role': role?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
