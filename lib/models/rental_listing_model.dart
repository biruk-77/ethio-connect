import 'dart:convert';
import 'post_model.dart';

class RentalListing {
  final String id;
  final String postId;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final int? squareFeet;
  final bool furnished;
  final List<String> amenities;
  final double? securityDeposit;
  final String? leaseDuration;
  final bool petsAllowed;
  final String? parkingSpaces;
  final List<String> photos;
  final Map<String, dynamic>? coordinates;
  final DateTime? availableFrom;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post;

  RentalListing({
    required this.id,
    required this.postId,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    this.squareFeet,
    this.furnished = false,
    this.amenities = const [],
    this.securityDeposit,
    this.leaseDuration,
    this.petsAllowed = false,
    this.parkingSpaces,
    this.photos = const [],
    this.coordinates,
    this.availableFrom,
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory RentalListing.fromJson(Map<String, dynamic> json) {
    // Parse amenities from JSON
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      try {
        if (json['amenities'] is String) {
          final decoded = jsonDecode(json['amenities']);
          amenitiesList = List<String>.from(decoded);
        } else if (json['amenities'] is List) {
          amenitiesList = List<String>.from(json['amenities']);
        }
      } catch (e) {
        amenitiesList = [];
      }
    }

    // Parse photos from JSON
    List<String> photosList = [];
    if (json['photos'] != null) {
      try {
        if (json['photos'] is String) {
          final decoded = jsonDecode(json['photos']);
          photosList = List<String>.from(decoded);
        } else if (json['photos'] is List) {
          photosList = List<String>.from(json['photos']);
        }
      } catch (e) {
        photosList = [];
      }
    }

    return RentalListing(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      propertyType: json['propertyType'] ?? 'apartment',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      squareFeet: json['squareFeet'],
      furnished: json['furnished'] ?? false,
      amenities: amenitiesList,
      securityDeposit: json['securityDeposit']?.toDouble(),
      leaseDuration: json['leaseDuration'],
      petsAllowed: json['petsAllowed'] ?? false,
      parkingSpaces: json['parkingSpaces'],
      photos: photosList,
      coordinates: json['coordinates'],
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : null,
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
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'furnished': furnished,
      'amenities': jsonEncode(amenities),
      'securityDeposit': securityDeposit,
      'leaseDuration': leaseDuration,
      'petsAllowed': petsAllowed,
      'parkingSpaces': parkingSpaces,
      'photos': jsonEncode(photos),
      'coordinates': coordinates,
      'availableFrom': availableFrom?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get full image URLs
  List<String> get fullImageUrls {
    return photos.map((pic) => 'https://ethiopost.unitybingo.com$pic').toList();
  }

  // Get first full image URL
  String? get firstImageUrl {
    if (photos.isEmpty) return null;
    return 'https://ethiopost.unitybingo.com${photos.first}';
  }

  String get formattedPropertyType {
    return propertyType.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String get bedroomBathroomText {
    return '$bedrooms bed${bedrooms != 1 ? 's' : ''}, $bathrooms bath${bathrooms != 1 ? 's' : ''}';
  }

  bool get isAvailable {
    if (availableFrom == null) return true;
    return DateTime.now().isAfter(availableFrom!);
  }
}
