class Profile {
  final String id;
  final String userId;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String? profession;
  final String? gender;
  final int? age;
  final List<String>? languages;
  final String? religion;
  final String? ethnicity;
  final String? education;
  final List<String>? interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.userId,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.profession,
    this.gender,
    this.age,
    this.languages,
    this.religion,
    this.ethnicity,
    this.education,
    this.interests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      profession: json['profession'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      religion: json['religion'] as String?,
      ethnicity: json['ethnicity'] as String?,
      education: json['education'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'profession': profession,
      'gender': gender,
      'age': age,
      'languages': languages,
      'religion': religion,
      'ethnicity': ethnicity,
      'education': education,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? profession,
    String? gender,
    int? age,
    List<String>? languages,
    String? religion,
    String? ethnicity,
    String? education,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      languages: languages ?? this.languages,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      education: education ?? this.education,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
