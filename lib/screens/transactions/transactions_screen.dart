import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../providers/expense_provider.dart';
import '../../models/transaction.dart' as trans;
import '../../components/swipeable_transaction_item.dart';
import '../../components/banner_ad_widget.dart';
import '../reports/financial_report_screen.dart';
import '../../services/currency_service.dart';

/// Transactions screen for viewing and managing all transactions
/// Redesigned to match the modern green-themed interface from the reference image
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedTimePeriod = 'All time';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter states
  String _filterType = 'All'; // All, Income, Expense
  String _sortBy = 'Newest'; // Newest, Oldest, Highest, Lowest
  final List<String> _selectedCategories = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Show filter modal with all filtering options
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Filter & Sort',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter by Type
                              _buildFilterSection(
                                'Filter by Type',
                                ['All', 'Income', 'Expense'],
                                _filterType,
                                (value) =>
                                    setModalState(() => _filterType = value),
                                setModalState,
                              ),
                              const SizedBox(height: 24),

                              // Sort by
                              _buildFilterSection(
                                'Sort by',
                                ['Newest', 'Oldest', 'Highest', 'Lowest'],
                                _sortBy,
                                (value) => setModalState(() => _sortBy = value),
                                setModalState,
                              ),
                              const SizedBox(height: 24),

                              // Filter by Category
                              _buildCategoryFilter(setModalState),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Apply Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {}); // Trigger rebuild with new filters
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true, // Handle keyboard properly
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () async {
              final provider = Provider.of<ExpenseProvider>(
                context,
                listen: false,
              );
              await _exportToPdf(context, provider.transactions);
            },
            tooltip: 'Export to PDF',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _showFilterModal,
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final allTransactions = provider.transactions;
          final filteredTransactions = _filterTransactions(allTransactions);

          return SafeArea(
            child: Column(
              children: [
                // Financial Report Banner - Now clickable
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => const FinancialReportScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'See your financial report',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                // Modern Enhanced Time Period Filter Chips
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        _buildModernTimePeriodChip(
                          'All time',
                          Icons.all_inclusive,
                        ),
                        const SizedBox(width: 6),
                        _buildModernTimePeriodChip('Today', Icons.today),
                        const SizedBox(width: 6),
                        _buildModernTimePeriodChip(
                          'This week',
                          Icons.date_range,
                        ),
                        const SizedBox(width: 6),
                        _buildModernTimePeriodChip(
                          'This month',
                          Icons.calendar_month,
                        ),
                        const SizedBox(width: 6),
                        _buildModernTimePeriodChip(
                          'This year',
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Enhanced, Modern Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search your transactions...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.clear_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                    size: 18,
                                  ),
                                ),
                              )
                              : null,
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Content Area - Expandable to handle keyboard
                Expanded(
                  child:
                      allTransactions.isEmpty
                          ? _buildEmptyState()
                          : filteredTransactions.isEmpty
                          ? _buildNoResultsState()
                          : _buildTransactionsList(filteredTransactions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build modern time period filter chip with enhanced design
  Widget _buildModernTimePeriodChip(String period, IconData icon) {
    final isSelected = _selectedTimePeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimePeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : (Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              period,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.secondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter section for the modal
  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
    StateSetter setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedValue == option;
                return GestureDetector(
                  onTap: () {
                    onChanged(option);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.shade100
                                  : Theme.of(context).colorScheme.surface),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.secondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build category filter section
  Widget _buildCategoryFilter(StateSetter setModalState) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final categories = [
          ...provider.incomeCategories,
          ...provider.expenseCategories,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                if (_selectedCategories.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategories.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              Text(
                'No categories available',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    categories.map((category) {
                      final isSelected = _selectedCategories.contains(
                        category.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              _selectedCategories.remove(category.id);
                            } else {
                              _selectedCategories.add(category.id);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey.shade100
                                        : Theme.of(
                                          context,
                                        ).colorScheme.surface),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.onSecondary
                                      : Theme.of(context).colorScheme.secondary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        );
      },
    );
  }

  /// Filter transactions based on all filter criteria
  List<trans.Transaction> _filterTransactions(
    List<trans.Transaction> transactions,
  ) {
    var filtered =
        transactions.where((transaction) {
          // Search query filter
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            if (!transaction.title.toLowerCase().contains(query) &&
                !(transaction.description?.toLowerCase().contains(query) ??
                    false)) {
              return false;
            }
          }

          // Type filter
          if (_filterType != 'All') {
            if (_filterType == 'Income' && transaction.type != 'income') {
              return false;
            }
            if (_filterType == 'Expense' && transaction.type != 'expense') {
              return false;
            }
          }

          // Category filter
          if (_selectedCategories.isNotEmpty) {
            if (!_selectedCategories.contains(transaction.categoryId)) {
              return false;
            }
          }

          // Time period filter
          final now = DateTime.now();
          final transactionDate = transaction.date;

          switch (_selectedTimePeriod) {
            case 'Today':
              if (transactionDate.year != now.year ||
                  transactionDate.month != now.month ||
                  transactionDate.day != now.day) {
                return false;
              }
              break;
            case 'This week':
              final weekAgo = now.subtract(const Duration(days: 7));
              if (transactionDate.isBefore(weekAgo)) {
                return false;
              }
              break;
            case 'This month':
              if (transactionDate.year != now.year ||
                  transactionDate.month != now.month) {
                return false;
              }
              break;
            case 'This year':
              if (transactionDate.year != now.year) {
                return false;
              }
              break;
            case 'All time':
            default:
              // No time filtering
              break;
          }

          return true;
        }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Newest':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  /// Build beautiful no results state when filters return empty list
  Widget _buildNoResultsState() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              200, // Account for app bar and other UI
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 50,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Matches Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _filterType = 'All';
                      _sortBy = 'Newest';
                      _selectedCategories.clear();
                      _selectedTimePeriod = 'All time';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build beautiful and engaging empty state when there are no transactions
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful animated illustration
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(90),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background circles for depth
                Positioned(
                  top: 20,
                  right: 30,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(17.5),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main icon with beautiful styling
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Secondary icons floating around
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFloatingIcon(Icons.add_circle_outline, -10),
                          const SizedBox(width: 40),
                          _buildFloatingIcon(Icons.trending_up, 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main heading with gradient text effect
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ],
                ).createShader(bounds),
            child: Text(
              '🎯 Ready to Track?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.surface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Beautiful description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your financial journey starts here!\nAdd your first transaction and watch your money insights come to life.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons with beautiful design
          Column(
            children: [
              // Primary action button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/add-transaction');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Your First Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Secondary tips
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quick Tips',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('💰', 'Track both income and expenses'),
                    _buildTipItem('📊', 'Use categories to organize better'),
                    _buildTipItem('🎯', 'Set budgets to stay on track'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build floating icon animation
  Widget _buildFloatingIcon(IconData icon, double offset) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
      ),
    );
  }

  /// Build tip item
  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build transactions list with consistent design matching home screen
  Widget _buildTransactionsList(List<trans.Transaction> transactions) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Calculate middle position for banner ad
        final int adPosition =
            transactions.length > 4
                ? (transactions.length / 2).floor()
                : transactions.length;
        final int totalItems =
            transactions.isNotEmpty
                ? transactions.length + 1
                : transactions.length; // +1 for banner ad

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // Show banner ad at middle position
            if (transactions.isNotEmpty && index == adPosition) {
              return const BannerAdWidget();
            }

            // Adjust transaction index if we're past the ad position
            final int transactionIndex =
                transactions.isNotEmpty && index > adPosition
                    ? index - 1
                    : index;

            // Return empty container if index is out of bounds (shouldn't happen)
            if (transactionIndex >= transactions.length) {
              return const SizedBox.shrink();
            }

            final transaction = transactions[transactionIndex];

            return SwipeableTransactionItem(
              key: Key(
                '${transaction.id}-${transaction.updatedAt.millisecondsSinceEpoch}',
              ),
              transaction: transaction,
              onDeleted: () {
                // Force complete state refresh to update totals and transaction list
                setState(() {
                  // Transaction deletion should trigger UI refresh
                });
                // Additional refresh after a small delay to ensure provider data is updated
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  /// Export transactions to PDF
  Future<void> _exportToPdf(
    BuildContext context,
    List<trans.Transaction> transactions,
  ) async {
    if (!mounted) return;

    try {
      // Small delay to ensure any pending navigation is complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Show loading dialog with proper context
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
      );

      final pdf = pw.Document();
      final currencyService = Provider.of<CurrencyService>(
        context,
        listen: false,
      );
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final now = DateTime.now();
      final filteredTransactions = _filterTransactions(transactions);

      // Check if still mounted before proceeding
      if (!mounted) return;

      // Calculate totals
      double totalIncome = 0;
      double totalExpenses = 0;
      for (final transaction in filteredTransactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: const pw.BoxDecoration(color: PdfColors.green800),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Vault Path',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            'Transaction Report',
                            style: pw.TextStyle(
                              fontSize: 16,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Generated on',
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                          pw.Text(
                            DateFormat('MMM dd, yyyy - HH:mm').format(now),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Summary Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Summary',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          pw.Column(
                            children: [
                              pw.Text(
                                'Total Income',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '${currencyService.currentCurrency.symbol}${totalIncome.toStringAsFixed(2)}',
                                style: const pw.TextStyle(
                                  color: PdfColors.green,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'Total Expenses',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '${currencyService.currentCurrency.symbol}${totalExpenses.toStringAsFixed(2)}',
                                style: const pw.TextStyle(color: PdfColors.red),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'Net Balance',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '${currencyService.currentCurrency.symbol}${(totalIncome - totalExpenses).toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  color:
                                      (totalIncome - totalExpenses) >= 0
                                          ? PdfColors.green
                                          : PdfColors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Filter Info
                if (_filterType != 'All' ||
                    _selectedCategories.isNotEmpty ||
                    _selectedTimePeriod != 'All time')
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(6),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Applied Filters:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        if (_filterType != 'All') pw.Text('Type: $_filterType'),
                        if (_selectedTimePeriod != 'All time')
                          pw.Text('Period: $_selectedTimePeriod'),
                        if (_selectedCategories.isNotEmpty)
                          pw.Text(
                            'Categories: ${_selectedCategories.length} selected',
                          ),
                      ],
                    ),
                  ),

                pw.SizedBox(height: 20),

                // Transactions Table
                pw.Text(
                  'Transactions (${filteredTransactions.length} items)',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                if (filteredTransactions.isEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Text(
                      'No transactions found with the current filters.',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                  )
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2), // Date
                      1: const pw.FlexColumnWidth(3), // Description
                      2: const pw.FlexColumnWidth(2), // Category
                      3: const pw.FlexColumnWidth(1.5), // Amount
                      4: const pw.FlexColumnWidth(1), // Type
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey200,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Description',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Category',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Amount',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Type',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...filteredTransactions.map((transaction) {
                        final category = provider.categories.firstWhere(
                          (cat) => cat.id == transaction.categoryId,
                          orElse: () => provider.categories.first,
                        );

                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                DateFormat('MMM dd').format(transaction.date),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(transaction.title),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(category.name),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${currencyService.currentCurrency.symbol}${transaction.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  color:
                                      transaction.type == 'income'
                                          ? PdfColors.green
                                          : PdfColors.red,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                transaction.type.toUpperCase(),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color:
                                      transaction.type == 'income'
                                          ? PdfColors.green
                                          : PdfColors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
              ],
        ),
      );

      // Save and open PDF
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/vault_path_transactions_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: false).pop();

        // Show success message with open option
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text('PDF exported successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF006E1F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Open PDF',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    // Use platform channel to open PDF
                    const platform = MethodChannel('com.budjar.file_opener');
                    await platform.invokeMethod('openFile', {
                      'path': file.path,
                    });
                  } catch (e) {
                    // Fallback: show file location dialog
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('PDF Exported Successfully!'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your transaction report has been saved.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Location:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: SelectableText(
                                      file.path,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'You can find this file in your device\'s Downloads folder or use a file manager app to open it.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: false).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
