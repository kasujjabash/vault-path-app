import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/category.dart';

/// Utility class for generating default data for new users
/// This class provides default accounts and categories to help users get started
class DefaultData {
  static const _uuid = Uuid();

  /// Get default categories for expense tracking
  static List<Category> getDefaultCategories() {
    final now = DateTime.now();

    return [
      // Expense Categories
      Category(
        id: _uuid.v4(),
        name: 'Food & Dining',
        type: 'expense',
        color: '#FF6B6B',
        icon: 'restaurant',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Transportation',
        type: 'expense',
        color: '#4ECDC4',
        icon: 'directions_car',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Shopping',
        type: 'expense',
        color: '#45B7D1',
        icon: 'shopping_bag',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Entertainment',
        type: 'expense',
        color: '#96CEB4',
        icon: 'movie',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Bills & Utilities',
        type: 'expense',
        color: '#FFEAA7',
        icon: 'receipt',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Healthcare',
        type: 'expense',
        color: '#DDA0DD',
        icon: 'local_hospital',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Education',
        type: 'expense',
        color: '#98D8C8',
        icon: 'school',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Travel',
        type: 'expense',
        color: '#F7DC6F',
        icon: 'flight',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Personal Care',
        type: 'expense',
        color: '#BB8FCE',
        icon: 'face',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Clothes',
        type: 'expense',
        color: '#E74C3C',
        icon: 'checkroom',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Coffee',
        type: 'expense',
        color: '#8D4B32',
        icon: 'local_cafe',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Debt',
        type: 'expense',
        color: '#C0392B',
        icon: 'money_off',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Drinks',
        type: 'expense',
        color: '#3498DB',
        icon: 'local_bar',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Electricity',
        type: 'expense',
        color: '#F39C12',
        icon: 'electrical_services',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Electronics',
        type: 'expense',
        color: '#34495E',
        icon: 'devices',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Gas Bill',
        type: 'expense',
        color: '#E67E22',
        icon: 'local_gas_station',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Groceries',
        type: 'expense',
        color: '#27AE60',
        icon: 'shopping_cart',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Internet',
        type: 'expense',
        color: '#3498DB',
        icon: 'wifi',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Phone Bill',
        type: 'expense',
        color: '#9B59B6',
        icon: 'phone',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Rent',
        type: 'expense',
        color: '#E74C3C',
        icon: 'home',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Restaurant',
        type: 'expense',
        color: '#FF6B6B',
        icon: 'restaurant_menu',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Spotify',
        type: 'expense',
        color: '#1DB954',
        icon: 'music_note',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Television',
        type: 'expense',
        color: '#2C3E50',
        icon: 'tv',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Utilities',
        type: 'expense',
        color: '#95A5A6',
        icon: 'build',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Water Bill',
        type: 'expense',
        color: '#3498DB',
        icon: 'water_drop',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'YouTube',
        type: 'expense',
        color: '#FF0000',
        icon: 'play_circle',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Personal',
        type: 'expense',
        color: '#FF69B4',
        icon: 'person',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Food',
        type: 'expense',
        color: '#FFA500',
        icon: 'fastfood',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Transport',
        type: 'expense',
        color: '#4169E1',
        icon: 'directions_bus',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Others',
        type: 'expense',
        color: '#85C1E9',
        icon: 'category',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),

      // Income Categories
      Category(
        id: _uuid.v4(),
        name: 'Borrowing',
        type: 'income',
        color: '#8B4513',
        icon: 'handshake',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Dividend',
        type: 'income',
        color: '#4CAF50',
        icon: 'attach_money',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Freelance',
        type: 'income',
        color: '#2196F3',
        icon: 'work_outline',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Passive Income',
        type: 'income',
        color: '#FF9800',
        icon: 'savings',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Pension',
        type: 'income',
        color: '#9C27B0',
        icon: 'elderly',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Profit',
        type: 'income',
        color: '#CDDC39',
        icon: 'trending_up',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Salary',
        type: 'income',
        color: '#009688',
        icon: 'payment',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Stocks',
        type: 'income',
        color: '#6A1B9A',
        icon: 'show_chart',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
    ];
  }

  /// Get default account for new users
  static Account getDefaultAccount() {
    final now = DateTime.now();

    return Account(
      id: _uuid.v4(),
      name: 'My Wallet',
      type: 'cash',
      balance: 0.0,
      description: 'Default cash account',
      color: '#6C63FF',
      icon: 'account_balance_wallet',
      isPrimary: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get predefined account types
  static List<Map<String, dynamic>> getAccountTypes() {
    return [
      {
        'type': 'checking',
        'name': 'Checking Account',
        'icon': 'account_balance',
        'color': '#4ECDC4',
        'description': 'For everyday transactions',
      },
      {
        'type': 'savings',
        'name': 'Savings Account',
        'icon': 'savings',
        'color': '#45B7D1',
        'description': 'For saving money',
      },
      {
        'type': 'credit',
        'name': 'Credit Card',
        'icon': 'credit_card',
        'color': '#FF6B6B',
        'description': 'Credit card account',
      },
      {
        'type': 'cash',
        'name': 'Cash',
        'icon': 'account_balance_wallet',
        'color': '#96CEB4',
        'description': 'Physical cash',
      },
      {
        'type': 'investment',
        'name': 'Investment',
        'icon': 'trending_up',
        'color': '#FFEAA7',
        'description': 'Investment account',
      },
    ];
  }

  /// Get predefined colors for UI customization
  static List<String> getPredefinedColors() {
    return [
      '#FF6B6B', // Red
      '#4ECDC4', // Teal
      '#45B7D1', // Blue
      '#96CEB4', // Green
      '#FFEAA7', // Yellow
      '#DDA0DD', // Purple
      '#98D8C8', // Mint
      '#F7DC6F', // Light Yellow
      '#BB8FCE', // Light Purple
      '#85C1E9', // Light Blue
      '#58D68D', // Light Green
      '#F8C471', // Orange
      '#F1948A', // Pink
      '#82E0AA', // Pale Green
      '#6C63FF', // Indigo
    ];
  }

  /// Get predefined icons for categories and accounts
  static List<String> getPredefinedIcons() {
    return [
      // General
      'category',
      'star',
      'favorite',
      'home',
      'work',

      // Money & Finance
      'account_balance',
      'account_balance_wallet',
      'attach_money',
      'credit_card',
      'savings',
      'trending_up',
      'trending_down',
      'receipt',

      // Food & Dining
      'restaurant',
      'local_cafe',
      'local_pizza',
      'cake',
      'local_bar',

      // Transportation
      'directions_car',
      'directions_bus',
      'local_taxi',
      'flight',
      'train',
      'motorcycle',
      'local_gas_station',

      // Shopping
      'shopping_bag',
      'shopping_cart',
      'store',
      'local_mall',
      'local_grocery_store',

      // Entertainment
      'movie',
      'music_note',
      'sports_esports',
      'local_movies',
      'theater_comedy',

      // Health & Personal Care
      'local_hospital',
      'face',
      'fitness_center',
      'spa',
      'local_pharmacy',

      // Education & Technology
      'school',
      'laptop',
      'phone',
      'computer',
      'book',

      // Utilities & Bills
      'lightbulb',
      'water_drop',
      'phone',
      'wifi',
      'electric_bolt',

      // Others
      'card_giftcard',
      'pets',
      'child_care',
      'agriculture',
      'construction',
    ];
  }
}
