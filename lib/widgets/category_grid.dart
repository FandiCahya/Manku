import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class CategoryGrid extends StatefulWidget {
  final Function(String)? onCategorySelected;

  const CategoryGrid({super.key, this.onCategorySelected});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  String? selectedCategory;

  final List<Map<String, String>> categories = [
    {'emoji': '🍔', 'label': 'Food'},
    {'emoji': '🚗', 'label': 'Trans'},
    {'emoji': '🛍️', 'label': 'Shop'},
    {'emoji': '💡', 'label': 'Bills'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: context.colors.secondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['label'];

            return GestureDetector(
              onTap: () {
                setState(() => selectedCategory = category['label']);
                widget.onCategorySelected?.call(category['label']!);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: context.colors.primary.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['emoji']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['label']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
