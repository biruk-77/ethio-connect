import 'post_model.dart';

class Service {
  final String id;
  final String postId;
  final String serviceType;
  final String rateType;
  final double? hourlyRate;
  final double? dailyRate;
  final double? projectRate;
  final String? currency;
  final List<String> skillsRequired;
  final String? availability;
  final String? portfolio;
  final int experience;
  final List<String> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post;

  Service({
    required this.id,
    required this.postId,
    required this.serviceType,
    required this.rateType,
    this.hourlyRate,
    this.dailyRate,
    this.projectRate,
    this.currency,
    this.skillsRequired = const [],
    this.availability,
    this.portfolio,
    this.experience = 0,
    this.certifications = const [],
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      serviceType: json['serviceType'] ?? '',
      rateType: json['rateType'] ?? 'hourly',
      hourlyRate: json['hourlyRate']?.toDouble(),
      dailyRate: json['dailyRate']?.toDouble(),
      projectRate: json['projectRate']?.toDouble(),
      currency: json['currency'] ?? 'ETB',
      skillsRequired: json['skillsRequired'] != null 
          ? List<String>.from(json['skillsRequired'])
          : [],
      availability: json['availability'],
      portfolio: json['portfolio'],
      experience: json['experience'] ?? 0,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'serviceType': serviceType,
      'rateType': rateType,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'projectRate': projectRate,
      'currency': currency,
      'skillsRequired': skillsRequired,
      'availability': availability,
      'portfolio': portfolio,
      'experience': experience,
      'certifications': certifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double? get preferredRate {
    switch (rateType) {
      case 'hourly':
        return hourlyRate;
      case 'daily':
        return dailyRate;
      case 'project':
        return projectRate;
      default:
        return hourlyRate;
    }
  }

  String get experienceLevel {
    if (experience < 1) return 'Entry Level';
    if (experience < 3) return 'Junior';
    if (experience < 5) return 'Mid-Level';
    if (experience < 10) return 'Senior';
    return 'Expert';
  }
}
