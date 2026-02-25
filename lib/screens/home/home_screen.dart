import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../components/expense_donut_chart.dart';
import '../../components/swipeable_transaction_item.dart';
import '../../components/home_drawer.dart';
import '../../components/banner_ad_widget.dart';
import '../more/premium_screen.dart';

/// Home screen with clean layout: Balance card, transactions, expense chart, and premium card
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMonthlyData();
        _checkNotificationReminders();
      }
    });
  }

  Future<void> _loadMonthlyData() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    try {
      await provider.getCurrentMonthExpenses();
      await provider.getCurrentMonthIncome();
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
    }
  }

  Future<void> _checkNotificationReminders() async {
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
    try {
      await notificationService.checkWeeklyReminders();
    } catch (e) {
      debugPrint('Error checking notification reminders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: const HomeDrawer(),
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            iconTheme: IconThemeData(
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            title: Text(
              'Vault Path',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                // fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            actions: [
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                        onPressed: () {
                          context.push('/notifications');
                        },
                      ),
                      if (notificationService.hasUnreadNotifications)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${notificationService.unreadCount}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Provider.of<ExpenseProvider>(
                context,
                listen: false,
              ).initialize();
              await _loadMonthlyData();
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Balance Card
                      _buildBalanceCard(),
                      const SizedBox(height: 24),

                      // Banner Ad
                      const BannerAdWidget(),

                      // Transactions
                      _buildSectionHeader('Transactions'),
                      const SizedBox(height: 12),
                      _buildRecentTransactions(),
                      const SizedBox(height: 24),

                      // Expense Chart
                      _buildSectionHeader('Expense Overview'),
                      const SizedBox(height: 12),
                      _buildExpenseStructure(),
                      const SizedBox(height: 24),

                      // Premium Card
                      _buildPremiumCard(),
                      const SizedBox(height: 100), // Space for FAB
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Create a unique key that changes when transaction data changes
        final transactionIds = provider.transactions.map((t) => t.id).join(',');
        final transactionHash = transactionIds.hashCode;

        return FutureBuilder<List<double>>(
          // Force rebuild when transactions actually change
          key: ValueKey(
            'balance-${provider.transactions.length}-$transactionHash',
          ),
          future: Future.wait([
            provider.getCurrentMonthIncome(),
            provider.getCurrentMonthExpenses(),
          ]),
          builder: (context, snapshot) {
            final totalIncome = snapshot.data?[0] ?? 0.0;
            final totalExpense = snapshot.data?[1] ?? 0.0;
            final balance = totalIncome - totalExpense;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 180,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),

              );
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isBalanceHidden = !_isBalanceHidden;
                          });
                        },
                        icon: Icon(
                          _isBalanceHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isBalanceHidden
                        ? '*****'
                        : balance < 0
                        ? '- ${FormatUtils.formatCurrency(balance.abs())}'
                        : FormatUtils.formatCurrency(balance),
                    style: TextStyle(
                      color:
                          balance < 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.secondary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Income',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isBalanceHidden
                                  ? '*****'
                                  : FormatUtils.formatCurrency(totalIncome),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Expense',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isBalanceHidden
                                ? '*****'
                                : '- ${FormatUtils.formatCurrency(totalExpense)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions.take(5).toList();

        if (transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first transaction to get started',
                  style: TextStyle(
                    fontSize: 14, 
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              transactions.map((transaction) {
                return SwipeableTransactionItem(
                  key: Key(
                    '${transaction.id}-${transaction.updatedAt.millisecondsSinceEpoch}',
                  ),
                  transaction: transaction,
                  onDeleted: () {
                    // Force complete refresh of transaction list and balance card
                    setState(() {
                      // This will trigger a rebuild of the entire screen
                    });
                    // Additional refresh after a small delay to ensure provider data is updated
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  },
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildExpenseStructure() {
    return const ExpenseDonutChart(
      size: 250,
      showLegend: true,
      showCenterText: true,
      
    );
  }

  Widget _buildPremiumCard() {
    return GestureDetector(
      onTap: () => showPremiumScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.diamond,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Get Premium',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Get Access to all feature & insights.\nUnlimited possibilities. No ads, more\nfeatures',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
