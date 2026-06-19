import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/report_summary.dart';

// Palet warna icon per kategori (fallback urutan)
const List<Color> _bgColors = [
  Color(0xFFfce4ec),
  Color(0xFFe3f2fd),
  Color(0xFFe8f5e9),
  Color(0xFFfff8e1),
  Color(0xFFede7f6),
  Color(0xFFfbe9e7),
];
const List<Color> _iconColors = [
  Color(0xFFe91e63),
  Color(0xFF1e88e5),
  Color(0xFF43a047),
  Color(0xFFffa000),
  Color(0xFF7b1fa2),
  Color(0xFFe64a19),
];

// Mapping nama kategori ke icon
const Map<String, IconData> _categoryIcons = {
  'Makanan': Icons.restaurant,
  'Food': Icons.restaurant,
  'Minuman': Icons.local_cafe,
  'Transportasi': Icons.directions_car,
  'Transport': Icons.directions_car,
  'Belanja': Icons.shopping_bag,
  'Shopping': Icons.shopping_bag,
  'Hiburan': Icons.celebration,
  'Entertainment': Icons.celebration,
  'Tagihan': Icons.receipt_long,
  'Bills': Icons.receipt_long,
  'Kesehatan': Icons.health_and_safety,
  'Health': Icons.health_and_safety,
  'Pendidikan': Icons.school,
  'Education': Icons.school,
  'Gaji': Icons.payments,
  'Salary': Icons.payments,
  'Lainnya': Icons.category,
  'Other': Icons.category,
};

IconData _iconForCategory(String name) {
  for (final key in _categoryIcons.keys) {
    if (name.toLowerCase().contains(key.toLowerCase())) {
      return _categoryIcons[key]!;
    }
  }
  return Icons.category;
}

class CategoryBreakdown extends StatefulWidget {
  final List<CategoryBreakdownItem>? categories;
  final bool isLoading;

  const CategoryBreakdown({
    super.key,
    this.categories,
    this.isLoading = false,
  });

  @override
  State<CategoryBreakdown> createState() => _CategoryBreakdownState();
}

class _CategoryBreakdownState extends State<CategoryBreakdown> {
  String _selectedFilter = 'all'; // 'all', 'income', 'expense'

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return 'Rp $buffer';
  }

  List<CategoryBreakdownItem> get _filteredCategories {
    final cats = widget.categories ?? [];
    if (_selectedFilter == 'all') return cats;
    return cats.where((cat) => cat.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = _filteredCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedFilter == 'all'
                          ? 'All transactions by category'
                          : _selectedFilter == 'income'
                              ? 'Income by category'
                              : 'Expenses by category',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All',
                value: 'all',
                icon: Icons.category_outlined,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Income',
                value: 'income',
                icon: Icons.arrow_upward_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Expense',
                value: 'expense',
                icon: Icons.arrow_downward_rounded,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        if (widget.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (cats.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _selectedFilter == 'all'
                    ? 'No transactions this month'
                    : _selectedFilter == 'income'
                        ? 'No income transactions this month'
                        : 'No expense transactions this month',
                style: TextStyle(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...List.generate(cats.length, (i) {
            final cat = cats[i];
            final bgColor = _bgColors[i % _bgColors.length];
            final iconColor = _iconColors[i % _iconColors.length];
            final progressColor = cat.type == 'income' 
                ? context.colors.mint 
                : context.colors.coral;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryItem(
                context: context,
                icon: _iconForCategory(cat.name),
                title: cat.name,
                subtitle: '${cat.count} transactions',
                amount: _formatCurrency(cat.amount),
                percentage: cat.percentage.clamp(0.0, 1.0),
                backgroundColor: bgColor,
                iconColor: iconColor,
                progressColor: progressColor,
                type: cat.type,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == value;
    
    Color chipColor;
    Color textColor;
    
    if (isSelected) {
      if (value == 'income') {
        chipColor = context.colors.mint;
        textColor = Colors.white;
      } else if (value == 'expense') {
        chipColor = context.colors.coral;
        textColor = Colors.white;
      } else {
        chipColor = context.colors.primary;
        textColor = Colors.white;
      }
    } else {
      chipColor = isDark ? const Color(0xFF253F55) : context.colors.surfaceContainerHigh;
      textColor = isDark ? Colors.white70 : context.colors.onSurfaceVariant;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required double percentage,
    required Color backgroundColor,
    required Color iconColor,
    required Color progressColor,
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type == 'income' 
              ? context.colors.mint.withValues(alpha: 0.2)
              : context.colors.coral.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : context.colors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: type == 'income'
                                      ? context.colors.mint.withValues(alpha: 0.15)
                                      : context.colors.coral.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type == 'income' ? 'IN' : 'OUT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: type == 'income' ? context.colors.mint : context.colors.coral,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: type == 'income'
                      ? context.colors.mint
                      : context.colors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: isDark 
                ? const Color(0xFF253F55) 
                : context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}% of total',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
