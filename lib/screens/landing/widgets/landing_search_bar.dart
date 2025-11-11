import 'package:flutter/material.dart';

class LandingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onFilterTap;

  const LandingSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmit,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmit,
            decoration: InputDecoration(
              hintText: 'Search anything...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                        if (onChanged != null) onChanged!('');
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    onPressed: onFilterTap,
                    tooltip: 'Filters',
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
