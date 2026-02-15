/// Data model for category spending information used in charts
class CategorySpendingData {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final String color;

  CategorySpendingData({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  String toString() {
    return 'CategorySpendingData(category: $categoryName, amount: $amount, percentage: ${percentage.toStringAsFixed(1)}%)';
  }
}
