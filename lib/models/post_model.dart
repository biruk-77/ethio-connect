import 'dart:convert';

class Post {
  final String id;
  final String userId;
  final String categoryId;
  final String postType;
  final String title;
  final String description;
  final String? price;
  final String? regionId;
  final String? cityId;
  final List<String> tags;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related objects
  final Category? category;
  final Region? region;
  final City? city;
  final Product? product;

  Post({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.postType,
    required this.title,
    required this.description,
    this.price,
    this.regionId,
    this.cityId,
    this.tags = const [],
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.region,
    this.city,
    this.product,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Parse tags from JSON string to list
    List<String> tagsList = [];
    if (json['tags'] != null) {
      try {
        if (json['tags'] is String) {
          final decoded = jsonDecode(json['tags']);
          tagsList = List<String>.from(decoded);
        } else if (json['tags'] is List) {
          tagsList = List<String>.from(json['tags']);
        }
      } catch (e) {
        tagsList = [];
      }
    }

    return Post(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      postType: json['postType'] ?? 'offer',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'],
      regionId: json['regionId'],
      cityId: json['cityId'],
      tags: tagsList,
      isActive: json['isActive'] ?? true,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'postType': postType,
      'title': title,
      'description': description,
      'price': price,
      'regionId': regionId,
      'cityId': cityId,
      'tags': jsonEncode(tags),
      'isActive': isActive,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Product {
  final String postId;
  final String productCategory;
  final String condition;
  final int stockQty;
  final String? sku;
  final bool allowOffers;
  final String? currency;
  final List<String> pictures;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post;

  Product({
    required this.postId,
    required this.productCategory,
    required this.condition,
    required this.stockQty,
    this.sku,
    this.allowOffers = true,
    this.currency,
    this.pictures = const [],
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse pictures from JSON string to list
    List<String> picturesList = [];
    if (json['pictures'] != null) {
      try {
        if (json['pictures'] is String) {
          final decoded = jsonDecode(json['pictures']);
          picturesList = List<String>.from(decoded);
        } else if (json['pictures'] is List) {
          picturesList = List<String>.from(json['pictures']);
        }
      } catch (e) {
        picturesList = [];
      }
    }

    return Product(
      postId: json['postId'] ?? '',
      productCategory: json['productCategory'] ?? '',
      condition: json['condition'] ?? 'used',
      stockQty: json['stockQty'] ?? 0,
      sku: json['sku'],
      allowOffers: json['allowOffers'] ?? true,
      currency: json['currency'],
      pictures: picturesList,
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
      'postId': postId,
      'productCategory': productCategory,
      'condition': condition,
      'stockQty': stockQty,
      'sku': sku,
      'allowOffers': allowOffers,
      'currency': currency,
      'pictures': jsonEncode(pictures),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get full image URLs
  List<String> getFullImageUrls(String baseUrl) {
    return pictures.map((pic) => '$baseUrl$pic').toList();
  }

  // Get first image URL
  String? getFirstImageUrl(String baseUrl) {
    if (pictures.isEmpty) return null;
    return '$baseUrl${pictures.first}';
  }
  
  // Get full image URLs using config
  List<String> get fullImageUrls {
    return pictures.map((pic) => 'https://ethiopost.unitybingo.com$pic').toList();
  }
  
  // Get first full image URL
  String? get firstImageUrl {
    if (pictures.isEmpty) return null;
    return 'https://ethiopost.unitybingo.com${pictures.first}';
  }
}

class Category {
  final String id;
  final String categoryName;
  final String? description;

  Category({
    required this.id,
    required this.categoryName,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
    };
  }
}

class Region {
  final String id;
  final String name;

  Region({
    required this.id,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
