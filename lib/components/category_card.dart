import 'package:flutter/material.dart';
import '../models/category.dart' as models;
import '../utils/format_utils.dart';

/// Simple, clean category card component
class CategoryCard extends StatelessWidget {
  final models.Category category;
  final bool isDefault;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    this.isDefault = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(FormatUtils.parseColorString(category.color));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(_getIconData(category.icon), color: Colors.white, size: 32),
            const SizedBox(height: 8),

            // Category Name
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Comprehensive icon mapping
    switch (iconName) {
      // Food & Dining
      case 'restaurant':
        return Icons.restaurant;
      case 'fastfood':
        return Icons.fastfood;
      case 'coffee':
        return Icons.coffee;
      case 'local_pizza':
        return Icons.local_pizza;

      // Transportation
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'local_gas_station':
        return Icons.local_gas_station;

      // Shopping
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'store':
        return Icons.store;

      // Bills & Utilities
      case 'receipt':
        return Icons.receipt;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'phone':
        return Icons.phone;
      case 'wifi':
        return Icons.wifi;

      // Entertainment
      case 'movie':
        return Icons.movie;
      case 'music_note':
        return Icons.music_note;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'headphones':
        return Icons.headphones;

      // Health & Medical
      case 'local_hospital':
        return Icons.local_hospital;
      case 'medical_services':
        return Icons.medical_services;
      case 'medication':
        return Icons.medication;
      case 'fitness_center':
        return Icons.fitness_center;

      // Home & Living
      case 'home':
        return Icons.home;
      case 'bed':
        return Icons.bed;
      case 'chair':
        return Icons.chair;

      // Work & Education
      case 'work':
        return Icons.work;
      case 'work_outline':
        return Icons.work_outline;
      case 'school':
        return Icons.school;
      case 'laptop':
        return Icons.laptop;
      case 'computer':
        return Icons.computer;
      case 'business':
        return Icons.business;

      // Finance & Income
      case 'payment':
        return Icons.payment;
      case 'trending_up':
        return Icons.trending_up;
      case 'attach_money':
        return Icons.attach_money;
      case 'account_balance':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'credit_card':
        return Icons.credit_card;

      // Personal & Lifestyle
      case 'person':
        return Icons.person;
      case 'face':
        return Icons.face;
      case 'pets':
        return Icons.pets;
      case 'child_care':
        return Icons.child_care;

      // Technology
      case 'smartphone':
        return Icons.smartphone;

      // Drinks
      case 'local_drink':
        return Icons.local_drink;
      case 'local_bar':
        return Icons.local_bar;

      // Default
      case 'category':
      default:
        return Icons.category;
    }
  }
}
