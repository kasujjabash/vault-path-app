import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/category.dart' as models;
import '../../utils/format_utils.dart';

/// Full-screen Categories Management Page
/// Shows expense and income categories with user and default categories sections
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF006E1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddCategoryDialog(),
            tooltip: 'Add Category',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.trending_down), text: 'Expenses'),
            Tab(icon: Icon(Icons.trending_up), text: 'Income'),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryTab('expense', provider.expenseCategories),
              _buildCategoryTab('income', provider.incomeCategories),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(String type, List<models.Category> categories) {
    // Separate default and user categories
    final defaultCategories = categories.where((cat) => cat.isDefault).toList();
    final userCategories = categories.where((cat) => !cat.isDefault).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Categories Section
          if (userCategories.isNotEmpty) ...[
            _buildSectionHeader('Your Categories', userCategories.length),
            const SizedBox(height: 12),
            _buildCategoriesGrid(userCategories, isDefault: false),
            const SizedBox(height: 32),
          ],

          // Default Categories Section
          _buildSectionHeader('Default Categories', defaultCategories.length),
          const SizedBox(height: 12),
          _buildCategoriesGrid(defaultCategories, isDefault: true),

          // Add Category Button
          const SizedBox(height: 24),
          _buildAddCategoryCard(type),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF006E1F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006E1F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(
    List<models.Category> categories, {
    required bool isDefault,
  }) {
    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isDefault ? 'No default categories' : 'No custom categories yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            if (!isDefault) ...[
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your first category',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, isDefault: isDefault);
      },
    );
  }

  Widget _buildCategoryCard(
    models.Category category, {
    required bool isDefault,
  }) {
    return GestureDetector(
      onTap: () => _showCategoryDetailDialog(category),
      onLongPress:
          isDefault ? null : () => _showCategoryOptionsDialog(category),
      child: Container(
        decoration: BoxDecoration(
          color: Color(
            FormatUtils.parseColorString(category.color),
          ).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(
              FormatUtils.parseColorString(category.color),
            ).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(FormatUtils.parseColorString(category.color)),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(
                      FormatUtils.parseColorString(category.color),
                    ).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Category Name
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(FormatUtils.parseColorString(category.color)),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Default badge
            if (isDefault) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryCard(String type) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(type: type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF006E1F).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF006E1F).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF006E1F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'Add ${type.substring(0, 1).toUpperCase()}${type.substring(1)} Category',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006E1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a custom category for your ${type}s',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetailDialog(models.Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(FormatUtils.parseColorString(category.color)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', category.type.toUpperCase()),
                _buildDetailRow('Color', category.color),
                _buildDetailRow('Icon', category.icon),
                _buildDetailRow('Default', category.isDefault ? 'Yes' : 'No'),
                _buildDetailRow(
                  'Created',
                  '${category.createdAt.day}/${category.createdAt.month}/${category.createdAt.year}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF006E1F)),
                ),
              ),
              if (!category.isDefault)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(category);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006E1F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit'),
                ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryOptionsDialog(models.Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(
                          FormatUtils.parseColorString(category.color),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(category.icon),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildOptionItem(
                  icon: Icons.edit,
                  title: 'Edit Category',
                  subtitle: 'Modify name, icon, or color',
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(category);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionItem(
                  icon: Icons.delete,
                  title: 'Delete Category',
                  subtitle: 'Remove this category permanently',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteCategoryDialog(category);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isDestructive ? Colors.red.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.grey.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDestructive
                              ? Colors.red.shade700
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog({String? type}) {
    // Implementation for add category dialog
    // This would show a form to create a new category
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add category dialog coming soon!'),
        backgroundColor: Color(0xFF006E1F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditCategoryDialog(models.Category category) {
    // Implementation for edit category dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit category dialog coming soon!'),
        backgroundColor: Color(0xFF006E1F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteCategoryDialog(models.Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF006E1F)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<ExpenseProvider>(
                      context,
                      listen: false,
                    ).deleteCategory(category.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${category.name} deleted successfully',
                          ),
                          backgroundColor: const Color(0xFF006E1F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting category: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'payment':
        return Icons.payment;
      case 'work_outline':
        return Icons.work_outline;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'category':
      default:
        return Icons.category;
    }
  }
}
