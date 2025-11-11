import 'package:flutter/material.dart';
import '../config/auth_api_config.dart';
import '../utils/app_logger.dart';

class ProductImageWidget extends StatelessWidget {
  final List<String> imagePaths;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductImageWidget({
    super.key,
    required this.imagePaths,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      AppLogger.warning('🖼️ No image paths provided for ProductImageWidget');
      return _buildPlaceholder(context);
    }

    // Get first image
    final firstImagePath = imagePaths.first;
    final fullImageUrl = '${AuthApiConfig.uploadsBaseUrl}$firstImagePath';
    
    AppLogger.info('🖼️ Loading product image: $fullImageUrl');

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.network(
        fullImageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            AppLogger.success('✅ Product image loaded successfully: $firstImagePath');
            return child;
          }
          
          final progress = loadingProgress.cumulativeBytesLoaded / 
              (loadingProgress.expectedTotalBytes ?? 1);
          AppLogger.info('⏳ Loading image... ${(progress * 100).toStringAsFixed(0)}%');
          
          return _buildLoadingIndicator(context);
        },
        errorBuilder: (context, error, stackTrace) {
          AppLogger.error('❌ Failed to load product image: $fullImageUrl - Error: $error');
          return _buildError(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// Gallery widget for multiple images
class ProductImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final BorderRadius? borderRadius;

  const ProductImageGallery({
    super.key,
    required this.imagePaths,
    this.height = 300,
    this.borderRadius,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      AppLogger.warning('🖼️ No images for ProductImageGallery');
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey.shade400,
        ),
      );
    }
    
    AppLogger.info('🎠 ProductImageGallery: ${widget.imagePaths.length} images');

    return Stack(
      children: [
        // Image PageView
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              AppLogger.info('📄 Gallery page changed to: ${index + 1}/${widget.imagePaths.length}');
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = widget.imagePaths[index];
              final fullImageUrl = '${AuthApiConfig.uploadsBaseUrl}$imagePath';

              return ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      AppLogger.success('✅ Gallery image ${index + 1} loaded: $imagePath');
                      return child;
                    }
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    AppLogger.error('❌ Gallery image ${index + 1} failed: $fullImageUrl - $error');
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Image indicators
        if (widget.imagePaths.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagePaths.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

        // Image counter
        if (widget.imagePaths.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imagePaths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Thumbnail grid for multiple images
class ProductImageGrid extends StatelessWidget {
  final List<String> imagePaths;
  final int maxImages;
  final double spacing;
  final VoidCallback? onMoreTap;

  const ProductImageGrid({
    super.key,
    required this.imagePaths,
    this.maxImages = 4,
    this.spacing = 4,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayImages = imagePaths.take(maxImages).toList();
    final remainingCount = imagePaths.length - maxImages;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        final isLast = index == displayImages.length - 1 && remainingCount > 0;
        final imagePath = displayImages[index];
        final fullImageUrl = '${AuthApiConfig.uploadsBaseUrl}$imagePath';

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
            if (isLast && onMoreTap != null)
              Positioned.fill(
                child: InkWell(
                  onTap: onMoreTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '+$remainingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
