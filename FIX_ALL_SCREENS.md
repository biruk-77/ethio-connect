# Model Property Corrections

## Issues Found:
1. `role.roleName` → Should be `role.role?.name`
2. `category?.title` → Should be `category?.categoryName`
3. `product?.images` → Should be `product?.pictures`
4. `product?.description` → Should be `post.description` (description is on Post, not Product)
5. `product?.price` → Should be `post.price` (price is on Post, not Product)
6. `PostDetailsSheet(post: post)` → Should be `PostDetailsSheet(postId: post.id)`

## Correct Model Properties:

### UserRole:
```dart
role.role?.name  // Access nested Role's name property
```

### Category:
```dart
category.categoryName  // NOT title
```

### Product:
```dart
product.pictures  // List<String> - NOT images
product.firstImageUrl  // Helper getter for first image with full URL
product.fullImageUrls  // Helper getter for all images with full URLs
```

### Post:
```dart
post.description  // Post has description
post.price  // Post has price (as String?)
post.product  // Product? - nested product object
```

## Fix Pattern:

```dart
// WRONG
role.roleName.toLowerCase()
post.category?.title.toLowerCase()
post.product?.images
post.product!.images.first
post.product?.description
post.product?.price

// CORRECT
role.role?.name?.toLowerCase() ?? ''
post.category?.categoryName.toLowerCase() ?? ''
post.product?.pictures
post.product!.firstImageUrl
post.description
post.price
```
