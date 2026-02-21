import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';
import '../../utils/custom_snackbar.dart';
import '../../models/transaction.dart' as trans;
import '../../models/category.dart' as models;
import '../../models/account.dart';

/// Modern Add Transaction Screen with clean interface
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'expense'; // Default to expense
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  String _repeatOption = 'Never';
  bool _isLoading = false;

  // Custom category creation controllers
  final _categoryNameController = TextEditingController();
  Color _selectedCategoryColor = Colors.blue;
  String _selectedCategoryIcon = 'category';

  @override
  void initState() {
    super.initState();
    // Get type from URL query parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final type = uri.queryParameters['type'];
      if (type != null && (type == 'income' || type == 'expense')) {
        setState(() {
          _transactionType = type;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Type Toggle
                        _buildTransactionTypeToggle(),
                        const SizedBox(height: 32),

                        // Amount Field
                        _buildAmountSection(),
                        const SizedBox(height: 32),

                        // Category Selection
                        _buildCategorySelection(),
                        const SizedBox(height: 24),

                        // Date and Repeat Row
                        Row(
                          children: [
                            Expanded(child: _buildDateSelection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRepeatSelection()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Payment Method
                        _buildPaymentMethodSelection(),
                        const SizedBox(height: 32),

                        // Quick Note
                        _buildQuickNoteSection(),

                        const SizedBox(height: 120), // Space for save button
                      ],
                    ),
                  ),
                ),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  //   // Build transaction type toggle (Expense/Income)
  //   Widget _buildTransactionTypeToggle() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Transaction type',
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           height: 50,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFD4E5D3), // Light green background
  //             borderRadius: BorderRadius.circular(25),
  //           ),
  //           child: Row(
  //             children: [
  //               // Expense Button
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: () => setState(() => _transactionType = 'expense'),
  //                   child: Container(
  //                     height: 50,
  //                     decoration: BoxDecoration(
  //                       color:
  //                           _transactionType == 'expense'
  //                               ? AppConstants.primaryColor
  //                               : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(25),
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         'Expense',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                           color:
  //                               _transactionType == 'expense'
  //                                   ? Colors.white
  //                                   : AppConstants.primaryColor,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               // Income Button
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: () => setState(() => _transactionType = 'income'),
  //                   child: Container(
  //                     height: 50,
  //                     decoration: BoxDecoration(
  //                       color:
  //                           _transactionType == 'income'
  //                               ? AppConstants.primaryColor
  //                               : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(25),
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         'Income',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                           color:
  //                               _transactionType == 'income'
  //                                   ? Colors.white
  //                                   : AppConstants.primaryColor,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   // Build amount input section
  //   Widget _buildAmountSection() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Amount',
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFD4E5D3), // Light green background
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: Row(
  //             children: [
  //               // USD Currency Label
  //               Container(
  //                 width: 60,
  //                 height: 60,
  //                 decoration: BoxDecoration(
  //                   color: AppConstants.primaryColor.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     'USD',
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w600,
  //                       color: AppConstants.primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               // Amount Input
  //               Expanded(
  //                 child: TextFormField(
  //                   controller: _amountController,
  //                   keyboardType: const TextInputType.numberWithOptions(
  //                     decimal: true,
  //                   ),
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.allow(
  //                       RegExp(r'^\d*\.?\d{0,2}'),
  //                     ),
  //                   ],
  //                   style: const TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.black87,
  //                   ),
  //                   decoration: InputDecoration(
  //                     hintText: '\$00',
  //                     hintStyle: const TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.grey,
  //                     ),
  //                     border: InputBorder.none,
  //                     contentPadding: const EdgeInsets.symmetric(
  //                       horizontal: 20,
  //                       vertical: 18,
  //                     ),
  //                   ),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please enter an amount';
  //                     }
  //                     if (double.tryParse(value) == null ||
  //                         double.parse(value) <= 0) {
  //                       return 'Please enter a valid amount';
  //                     }
  //                     return null;
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   // Build category selection
  //   Widget _buildCategorySelection() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Select Category',
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         GestureDetector(
  //           onTap: _showCategorySelector,
  //           child: Container(
  //             height: 60,
  //             padding: const EdgeInsets.symmetric(horizontal: 20),
  //             decoration: BoxDecoration(
  //               border: Border.all(color: AppConstants.primaryColor, width: 2),
  //               borderRadius: BorderRadius.circular(30),
  //             ),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   width: 40,
  //                   height: 40,
  //                   decoration: BoxDecoration(
  //                     color: AppConstants.primaryColor,
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                   child: const Icon(Icons.add, color: Colors.white, size: 20),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Expanded(
  //                   child: Text(
  //                     _selectedCategoryId != null
  //                         ? _getCategoryName(_selectedCategoryId!)
  //                         : 'Tap to select category',
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color:
  //                           _selectedCategoryId != null
  //                               ? Colors.black87
  //                               : Colors.grey,
  //                     ),
  //                   ),
  //                 ),
  //                 Icon(
  //                   Icons.keyboard_arrow_down,
  //                   color: AppConstants.primaryColor,
  //                   size: 24,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   // Build date selection
  //   Widget _buildDateSelection() {
  //     return GestureDetector(
  //       onTap: _selectDate,
  //       child: Container(
  //         height: 60,
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: AppConstants.primaryColor, width: 2),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.calendar_today,
  //               color: AppConstants.primaryColor,
  //               size: 20,
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 _isToday() ? 'Today' : _formatDate(_selectedDate),
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //             Icon(
  //               Icons.keyboard_arrow_down,
  //               color: AppConstants.primaryColor,
  //               size: 24,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   // Build repeat selection
  //   Widget _buildRepeatSelection() {
  //     return GestureDetector(
  //       onTap: _showRepeatOptions,
  //       child: Container(
  //         height: 60,
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: AppConstants.primaryColor, width: 2),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(Icons.repeat, color: AppConstants.primaryColor, size: 20),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 _repeatOption,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //             Icon(
  //               Icons.keyboard_arrow_down,
  //               color: AppConstants.primaryColor,
  //               size: 24,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   // Build payment method selection
  //   Widget _buildPaymentMethodSelection() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         GestureDetector(
  //           onTap: _showPaymentMethodOptions,
  //           child: Container(
  //             height: 60,
  //             padding: const EdgeInsets.symmetric(horizontal: 20),
  //             decoration: BoxDecoration(
  //               border: Border.all(color: AppConstants.primaryColor, width: 2),
  //               borderRadius: BorderRadius.circular(30),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   _getPaymentMethodIcon(_paymentMethod),
  //                   color: AppConstants.primaryColor,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Expanded(
  //                   child: Text(
  //                     _paymentMethod,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                 ),
  //                 Icon(
  //                   Icons.keyboard_arrow_down,
  //                   color: AppConstants.primaryColor,
  //                   size: 24,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   // Build quick note section
  //   Widget _buildQuickNoteSection() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 24,
  //               height: 24,
  //               decoration: BoxDecoration(
  //                 color: AppConstants.primaryColor,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Icon(Icons.edit, color: Colors.white, size: 14),
  //             ),
  //             const SizedBox(width: 12),
  //             Text(
  //               'Quick Note',
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey.shade300),
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: TextFormField(
  //             controller: _noteController,
  //             maxLines: 1,
  //             style: const TextStyle(fontSize: 16, color: Colors.black87),
  //             decoration: InputDecoration(
  //               hintText: 'Enter a note ...',
  //               hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
  //               border: InputBorder.none,
  //               contentPadding: EdgeInsets.zero,
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   // Build save button
  //   Widget _buildSaveButton() {
  //     return Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.all(24),
  //       child: ElevatedButton(
  //         onPressed: _isLoading ? null : _saveTransaction,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: AppConstants.primaryColor,
  //           foregroundColor: Colors.white,
  //           padding: const EdgeInsets.symmetric(vertical: 20),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           elevation: 0,
  //         ),
  //         child:
  //             _isLoading
  //                 ? const SizedBox(
  //                   height: 20,
  //                   width: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                   ),
  //                 )
  //                 : Text(
  //                   'Save',
  //                   style: const TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //       ),
  //     );
  //   }

  //   // Helper method to check if selected date is today
  //   bool _isToday() {
  //     final now = DateTime.now();
  //     return _selectedDate.year == now.year &&
  //         _selectedDate.month == now.month &&
  //         _selectedDate.day == now.day;
  //   }

  //   // Helper method to format date
  //   String _formatDate(DateTime date) {
  //     return '${date.day}/${date.month}/${date.year}';
  //   }

  //   // Handle date selection
  //   Future<void> _selectDate() async {
  //     final picked = await showDatePicker(
  //       context: context,
  //       initialDate: _selectedDate,
  //       firstDate: DateTime(2020),
  //       lastDate: DateTime.now().add(const Duration(days: 365)),
  //     );
  //     if (picked != null && picked != _selectedDate) {
  //       setState(() {
  //         _selectedDate = picked;
  //       });
  //     }
  //   }

  //   // Show category selector
  //   void _showCategorySelector() {
  //     final provider = Provider.of<ExpenseProvider>(context, listen: false);
  //     final categories =
  //         _transactionType == 'income'
  //             ? provider.incomeCategories
  //             : provider.expenseCategories;

  //     // Add predefined categories if none exist
  //     final predefinedCategories = _getPredefinedCategories();
  //     final allCategories = [...categories];

  //     // Add predefined categories that don't already exist
  //     for (final predefined in predefinedCategories) {
  //       final name = predefined['name']!;
  //       final icon = predefined['icon']!;
  //       final color = predefined['color']!;

  //       if (!allCategories.any(
  //         (cat) => cat.name.toLowerCase() == name.toLowerCase(),
  //       )) {
  //         allCategories.add(
  //           models.Category(
  //             id: DateTime.now().millisecondsSinceEpoch.toString() + name,
  //             name: name,
  //             icon: icon,
  //             color: color,
  //             type: _transactionType,
  //             isDefault: true,
  //             createdAt: DateTime.now(),
  //             updatedAt: DateTime.now(),
  //           ),
  //         );
  //       }
  //     }

  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       isScrollControlled: true,
  //       builder:
  //           (context) => Container(
  //             height: MediaQuery.of(context).size.height * 0.8,
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(20),
  //                 topRight: Radius.circular(20),
  //               ),
  //             ),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   width: 40,
  //                   height: 4,
  //                   margin: const EdgeInsets.only(top: 12),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade300,
  //                     borderRadius: BorderRadius.circular(2),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(20),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'Select Category',
  //                         style: const TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w600,
  //                           color: AppConstants.primaryColor,
  //                         ),
  //                       ),
  //                       TextButton.icon(
  //                         onPressed: _showAddCategoryDialog,
  //                         icon: const Icon(
  //                           Icons.add,
  //                           color: AppConstants.primaryColor,
  //                         ),
  //                         label: const Text(
  //                           'Add Custom',
  //                           style: TextStyle(color: AppConstants.primaryColor),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: GridView.builder(
  //                     padding: const EdgeInsets.symmetric(horizontal: 20),
  //                     gridDelegate:
  //                         const SliverGridDelegateWithFixedCrossAxisCount(
  //                           crossAxisCount: 3,
  //                           crossAxisSpacing: 12,
  //                           mainAxisSpacing: 12,
  //                           childAspectRatio: 1,
  //                         ),
  //                     itemCount: allCategories.length,
  //                     itemBuilder: (context, index) {
  //                       final category = allCategories[index];
  //                       final isSelected = _selectedCategoryId == category.id;
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             _selectedCategoryId = category.id;
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             color:
  //                                 isSelected
  //                                     ? Color(
  //                                       FormatUtils.parseColorString(
  //                                         category.color,
  //                                       ),
  //                                     ).withOpacity(0.3)
  //                                     : Color(
  //                                       FormatUtils.parseColorString(
  //                                         category.color,
  //                                       ),
  //                                     ).withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(12),
  //                             border:
  //                                 isSelected
  //                                     ? Border.all(
  //                                       color: Color(
  //                                         FormatUtils.parseColorString(
  //                                           category.color,
  //                                         ),
  //                                       ),
  //                                       width: 2,
  //                                     )
  //                                     : null,
  //                           ),
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 _getIconData(category.icon),
  //                                 color: Color(
  //                                   FormatUtils.parseColorString(category.color),
  //                                 ),
  //                                 size: 32,
  //                               ),
  //                               const SizedBox(height: 8),
  //                               Text(
  //                                 category.name,
  //                                 style: TextStyle(
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.w500,
  //                                   color: Color(
  //                                     FormatUtils.parseColorString(
  //                                       category.color,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 textAlign: TextAlign.center,
  //                                 maxLines: 2,
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //     );
  //   }

  //   // Show repeat options
  //   void _showRepeatOptions() {
  //     final repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       builder:
  //           (context) => Container(
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(20),
  //                 topRight: Radius.circular(20),
  //               ),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Container(
  //                   width: 40,
  //                   height: 4,
  //                   margin: const EdgeInsets.only(top: 12),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade300,
  //                     borderRadius: BorderRadius.circular(2),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(20),
  //                   child: Text(
  //                     'Repeat Option',
  //                     style: const TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                       color: AppConstants.primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //                 ...repeatOptions.map(
  //                   (option) => ListTile(
  //                     title: Text(option),
  //                     trailing:
  //                         _repeatOption == option
  //                             ? Icon(
  //                               Icons.check,
  //                               color: AppConstants.primaryColor,
  //                             )
  //                             : null,
  //                     onTap: () {
  //                       setState(() {
  //                         _repeatOption = option;
  //                       });
  //                       Navigator.pop(context);
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //     );
  //   }

  //   // Show payment method options
  //   void _showPaymentMethodOptions() {
  //     final paymentMethods = [
  //       {'name': 'Cash', 'icon': Icons.payments},
  //       {'name': 'Credit Card', 'icon': Icons.credit_card},
  //       {'name': 'Debit Card', 'icon': Icons.credit_card_outlined},
  //       {'name': 'Mobile Money', 'icon': Icons.phone_android},
  //       {'name': 'PayPal', 'icon': Icons.account_balance_wallet},
  //       {'name': 'Stripe', 'icon': Icons.payment},
  //     ];

  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       builder:
  //           (context) => Container(
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(20),
  //                 topRight: Radius.circular(20),
  //               ),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Container(
  //                   width: 40,
  //                   height: 4,
  //                   margin: const EdgeInsets.only(top: 12),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade300,
  //                     borderRadius: BorderRadius.circular(2),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(20),
  //                   child: Text(
  //                     'Payment Method',
  //                     style: const TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                       color: AppConstants.primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //                 ...paymentMethods.map(
  //                   (method) => ListTile(
  //                     leading: Container(
  //                       width: 40,
  //                       height: 40,
  //                       decoration: BoxDecoration(
  //                         color: AppConstants.primaryColor.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Icon(
  //                         method['icon'] as IconData,
  //                         color: AppConstants.primaryColor,
  //                         size: 20,
  //                       ),
  //                     ),
  //                     title: Text(method['name'] as String),
  //                     trailing:
  //                         _paymentMethod == method['name']
  //                             ? const Icon(
  //                               Icons.check,
  //                               color: AppConstants.primaryColor,
  //                             )
  //                             : null,
  //                     onTap: () {
  //                       setState(() {
  //                         _paymentMethod = method['name'] as String;
  //                       });
  //                       Navigator.pop(context);
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //     );
  //   }

  //   // Get predefined categories
  //   List<Map<String, String>> _getPredefinedCategories() {
  //     if (_transactionType == 'income') {
  //       return [
  //         {'name': 'Salary', 'icon': 'work', 'color': '0xFF4CAF50'},
  //         {'name': 'Business', 'icon': 'business', 'color': '0xFF2196F3'},
  //         {'name': 'Investment', 'icon': 'trending_up', 'color': '0xFF9C27B0'},
  //         {'name': 'Gift', 'icon': 'card_giftcard', 'color': '0xFFFF9800'},
  //         {'name': 'Freelance', 'icon': 'laptop', 'color': '0xFF795548'},
  //         {'name': 'Rental', 'icon': 'home', 'color': '0xFF607D8B'},
  //         {'name': 'Bonus', 'icon': 'star', 'color': '0xFFFFEB3B'},
  //         {'name': 'Commission', 'icon': 'percent', 'color': '0xFF3F51B5'},
  //       ];
  //     } else {
  //       return [
  //         {'name': 'Food & Dining', 'icon': 'restaurant', 'color': '0xFFFF5722'},
  //         {
  //           'name': 'Transportation',
  //           'icon': 'directions_car',
  //           'color': '0xFF2196F3',
  //         },
  //         {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '0xFFE91E63'},
  //         {'name': 'Entertainment', 'icon': 'movie', 'color': '0xFF9C27B0'},
  //         {'name': 'Bills & Utilities', 'icon': 'receipt', 'color': '0xFF607D8B'},
  //         {'name': 'Healthcare', 'icon': 'local_hospital', 'color': '0xFFF44336'},
  //         {'name': 'Education', 'icon': 'school', 'color': '0xFF4CAF50'},
  //         {'name': 'Travel', 'icon': 'flight', 'color': '0xFF00BCD4'},
  //         {'name': 'Personal Care', 'icon': 'face', 'color': '0xFFFF9800'},
  //         {
  //           'name': 'Groceries',
  //           'icon': 'local_grocery_store',
  //           'color': '0xFF8BC34A',
  //         },
  //         {'name': 'Rent', 'icon': 'home', 'color': '0xFF795548'},
  //         {'name': 'Insurance', 'icon': 'security', 'color': '0xFF3F51B5'},
  //         {'name': 'Gas', 'icon': 'local_gas_station', 'color': '0xFFFF5722'},
  //         {'name': 'Coffee & Tea', 'icon': 'local_cafe', 'color': '0xFF795548'},
  //         {'name': 'Fitness', 'icon': 'fitness_center', 'color': '0xFF4CAF50'},
  //         {
  //           'name': 'Subscriptions',
  //           'icon': 'subscriptions',
  //           'color': '0xFF9C27B0',
  //         },
  //         {'name': 'Clothing', 'icon': 'checkroom', 'color': '0xFFE91E63'},
  //         {'name': 'Electronics', 'icon': 'devices', 'color': '0xFF607D8B'},
  //         {'name': 'Books', 'icon': 'menu_book', 'color': '0xFF795548'},
  //         {'name': 'Gifts', 'icon': 'card_giftcard', 'color': '0xFFFF9800'},
  //         {'name': 'Pharmacy', 'icon': 'local_pharmacy', 'color': '0xFFF44336'},
  //         {'name': 'Pet Care', 'icon': 'pets', 'color': '0xFF8BC34A'},
  //         {'name': 'Home Improvement', 'icon': 'build', 'color': '0xFF607D8B'},
  //         {'name': 'Taxes', 'icon': 'account_balance', 'color': '0xFF3F51B5'},
  //         {'name': 'Other', 'icon': 'category', 'color': '0xFF9E9E9E'},
  //       ];
  //     }
  //   }

  //   // Get payment method icon
  //   IconData _getPaymentMethodIcon(String method) {
  //     switch (method) {
  //       case 'Credit Card':
  //         return Icons.credit_card;
  //       case 'Debit Card':
  //         return Icons.credit_card_outlined;
  //       case 'Mobile Money':
  //         return Icons.phone_android;
  //       case 'PayPal':
  //         return Icons.account_balance_wallet;
  //       case 'Stripe':
  //         return Icons.payment;
  //       case 'Cash':
  //       default:
  //         return Icons.payments;
  //     }
  //   }

  //   // Show add custom category dialog
  //   void _showAddCategoryDialog() {
  //     _categoryNameController.clear();
  //     _selectedCategoryColor = Colors.blue;
  //     _selectedCategoryIcon = 'category';

  //     showDialog(
  //       context: context,
  //       builder:
  //           (context) => AlertDialog(
  //             title: const Text(
  //               'Add Custom Category',
  //               style: TextStyle(
  //                 color: AppConstants.primaryColor,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             content: StatefulBuilder(
  //               builder:
  //                   (context, setDialogState) => Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       // Category Name Input
  //                       TextField(
  //                         controller: _categoryNameController,
  //                         decoration: InputDecoration(
  //                           labelText: 'Category Name',
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: const BorderSide(
  //                               color: AppConstants.primaryColor,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 20),

  //                       // Color Selection
  //                       const Text(
  //                         'Choose Color',
  //                         style: TextStyle(fontWeight: FontWeight.w500),
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Wrap(
  //                         spacing: 10,
  //                         children:
  //                             [
  //                                   Colors.red,
  //                                   Colors.blue,
  //                                   Colors.green,
  //                                   Colors.orange,
  //                                   Colors.purple,
  //                                   Colors.teal,
  //                                   Colors.pink,
  //                                   Colors.indigo,
  //                                 ]
  //                                 .map(
  //                                   (color) => GestureDetector(
  //                                     onTap: () {
  //                                       setDialogState(() {
  //                                         _selectedCategoryColor = color;
  //                                       });
  //                                     },
  //                                     child: Container(
  //                                       width: 40,
  //                                       height: 40,
  //                                       decoration: BoxDecoration(
  //                                         color: color,
  //                                         shape: BoxShape.circle,
  //                                         border:
  //                                             _selectedCategoryColor == color
  //                                                 ? Border.all(
  //                                                   color: Colors.black,
  //                                                   width: 3,
  //                                                 )
  //                                                 : null,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                       ),
  //                       const SizedBox(height: 20),

  //                       // Icon Selection
  //                       const Text(
  //                         'Choose Icon',
  //                         style: TextStyle(fontWeight: FontWeight.w500),
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Wrap(
  //                         spacing: 10,
  //                         children:
  //                             [
  //                                   'restaurant',
  //                                   'shopping_bag',
  //                                   'directions_car',
  //                                   'movie',
  //                                   'receipt',
  //                                   'local_hospital',
  //                                   'school',
  //                                   'home',
  //                                   'work',
  //                                   'fitness_center',
  //                                   'pets',
  //                                   'category',
  //                                 ]
  //                                 .map(
  //                                   (iconName) => GestureDetector(
  //                                     onTap: () {
  //                                       setDialogState(() {
  //                                         _selectedCategoryIcon = iconName;
  //                                       });
  //                                     },
  //                                     child: Container(
  //                                       width: 40,
  //                                       height: 40,
  //                                       decoration: BoxDecoration(
  //                                         color:
  //                                             _selectedCategoryIcon == iconName
  //                                                 ? _selectedCategoryColor
  //                                                     .withOpacity(0.3)
  //                                                 : Colors.grey.shade200,
  //                                         borderRadius: BorderRadius.circular(8),
  //                                         border:
  //                                             _selectedCategoryIcon == iconName
  //                                                 ? Border.all(
  //                                                   color: _selectedCategoryColor,
  //                                                   width: 2,
  //                                                 )
  //                                                 : null,
  //                                       ),
  //                                       child: Icon(
  //                                         _getIconData(iconName),
  //                                         color:
  //                                             _selectedCategoryIcon == iconName
  //                                                 ? _selectedCategoryColor
  //                                                 : Colors.grey.shade600,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                       ),
  //                     ],
  //                   ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('Cancel'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: _createCustomCategory,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppConstants.primaryColor,
  //                 ),
  //                 child: const Text(
  //                   'Create',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ],
  //           ),
  //     );
  //   }

  //   // Create custom category
  //   void _createCustomCategory() async {
  //     if (_categoryNameController.text.trim().isEmpty) {
  //       CustomSnackBar.showError(context, 'Please enter a category name');
  //       return;
  //     }

  //     try {
  //       final provider = Provider.of<ExpenseProvider>(context, listen: false);
  //       final categoryId = DateTime.now().millisecondsSinceEpoch.toString();

  //       final category = models.Category(
  //         id: categoryId,
  //         name: _categoryNameController.text.trim(),
  //         icon: _selectedCategoryIcon,
  //         color:
  //             '0x${_selectedCategoryColor.value.toRadixString(16).toUpperCase()}',
  //         type: _transactionType,
  //         isDefault: false,
  //         createdAt: DateTime.now(),
  //         updatedAt: DateTime.now(),
  //       );

  //       await provider.addCategory(category);

  //       setState(() {
  //         _selectedCategoryId = categoryId;
  //       });

  //       Navigator.pop(context); // Close custom category dialog
  //       Navigator.pop(context); // Close category selector dialog

  //       CustomSnackBar.showSuccess(context, 'Category created successfully!');
  //     } catch (e) {
  //       CustomSnackBar.showError(context, 'Failed to create category: $e');
  //     }
  //   }

  //   // Get category name by ID
  //   String _getCategoryName(String categoryId) {
  //     final provider = Provider.of<ExpenseProvider>(context, listen: false);
  //     final categories =
  //         _transactionType == 'income'
  //             ? provider.incomeCategories
  //             : provider.expenseCategories;

  //     final category = categories.firstWhere(
  //       (cat) => cat.id == categoryId,
  //       orElse:
  //           () => models.Category(
  //             id: '',
  //             name: 'Unknown Category',
  //             type: 'expense',
  //             color: 'FF006E1F',
  //             icon: 'category',
  //             isDefault: false,
  //             createdAt: DateTime.now(),
  //             updatedAt: DateTime.now(),
  //           ),
  //     );
  //     return category.name;
  //   }

  //   // Save transaction
  //   Future<void> _saveTransaction() async {
  //     if (!_formKey.currentState!.validate()) {
  //       return;
  //     }

  //     if (_selectedCategoryId == null) {
  //       CustomSnackBar.showError(context, 'Please select a category');
  //       return;
  //     }

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       final provider = Provider.of<ExpenseProvider>(context, listen: false);
  //       final amount = double.parse(_amountController.text);

  //       // Get or create a default account
  //       String accountId = _selectedAccountId ?? 'default_cash_account';

  //       // Create a default account if needed
  //       if (_selectedAccountId == null) {
  //         // Create a default cash account for the payment method
  //         accountId = await _ensureDefaultAccount(provider);
  //       }

  //       final transaction = trans.Transaction(
  //         id: DateTime.now().millisecondsSinceEpoch.toString(),
  //         title: _getCategoryName(_selectedCategoryId!),
  //         description:
  //             _noteController.text.trim().isEmpty
  //                 ? null
  //                 : _noteController.text.trim(),
  //         amount: amount,
  //         type: _transactionType,
  //         categoryId: _selectedCategoryId!,
  //         accountId: accountId,
  //         date: _selectedDate,
  //         createdAt: DateTime.now(),
  //         updatedAt: DateTime.now(),
  //       );

  //       await provider.addTransaction(transaction);

  //       if (mounted) {
  //         CustomSnackBar.showSuccess(context, 'Transaction saved successfully!');
  //         Navigator.of(context).pop();
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         CustomSnackBar.showError(context, 'Error saving transaction: $e');
  //       }
  //     } finally {
  //       if (mounted) {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     }
  //   }

  //   // Ensure default account exists
  //   Future<String> _ensureDefaultAccount(ExpenseProvider provider) async {
  //     // Check if default account already exists
  //     final existingAccount =
  //         provider.accounts
  //             .where((account) => account.name == _paymentMethod)
  //             .firstOrNull;

  //     if (existingAccount != null) {
  //       return existingAccount.id;
  //     }

  //     // Create a new account for this payment method
  //     // Note: This is a simplified approach. In a real app, you might want to handle this differently.
  //     return 'default_' + _paymentMethod.toLowerCase().replaceAll(' ', '_');
  //   }

  //   // Get icon data
  //   IconData _getIconData(String iconName) {
  //     const iconMap = {
  //       'restaurant': Icons.restaurant,
  //       'directions_car': Icons.directions_car,
  //       'shopping_bag': Icons.shopping_bag,
  //       'movie': Icons.movie,
  //       'receipt': Icons.receipt,
  //       'local_hospital': Icons.local_hospital,
  //       'school': Icons.school,
  //       'flight': Icons.flight,
  //       'face': Icons.face,
  //       'category': Icons.category,
  //       'work': Icons.work,
  //       'laptop': Icons.laptop,
  //       'trending_up': Icons.trending_up,
  //       'card_giftcard': Icons.card_giftcard,
  //       'attach_money': Icons.attach_money,
  //       'account_balance_wallet': Icons.account_balance_wallet,
  //       'account_balance': Icons.account_balance,
  //       'savings': Icons.savings,
  //       'credit_card': Icons.credit_card,
  //       'home': Icons.home,
  //       'local_grocery_store': Icons.local_grocery_store,
  //       'security': Icons.security,
  //       'local_gas_station': Icons.local_gas_station,
  //       'local_cafe': Icons.local_cafe,
  //       'fitness_center': Icons.fitness_center,
  //       'subscriptions': Icons.subscriptions,
  //       'checkroom': Icons.checkroom,
  //       'devices': Icons.devices,
  //       'menu_book': Icons.menu_book,
  //       'local_pharmacy': Icons.local_pharmacy,
  //       'pets': Icons.pets,
  //       'build': Icons.build,
  //       'business': Icons.business,
  //       'star': Icons.star,
  //       'percent': Icons.percent,
  //     };
  //     return iconMap[iconName] ?? Icons.category;
  //   }

  // Essential UI Builder Methods

  /// Build transaction type toggle (Expense/Income)
  Widget _buildTransactionTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 60,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _transactionType = 'expense'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          _transactionType == 'expense'
                              ? Colors.red.shade500
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          _transactionType == 'expense'
                              ? [
                                BoxShadow(
                                  color: Colors.red.shade300,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color:
                              _transactionType == 'expense'
                                  ? Colors.white
                                  : Colors.red.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _transactionType == 'expense'
                                    ? Colors.white
                                    : Colors.red.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _transactionType = 'income'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          _transactionType == 'income'
                              ? Colors.green.shade500
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          _transactionType == 'income'
                              ? [
                                BoxShadow(
                                  color: Colors.green.shade300,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color:
                              _transactionType == 'income'
                                  ? Colors.white
                                  : Colors.green.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _transactionType == 'income'
                                    ? Colors.white
                                    : Colors.green.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build amount input section
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  border: Border(
                    right: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'USD',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build category selection - FIXED: Proper scrolling and icon colors
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCategorySelector,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedCategoryId != null
                        ? _getCategoryName(_selectedCategoryId!)
                        : 'Select category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedCategoryId != null
                              ? Colors.black87
                              : Colors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build date selection
  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                FormatUtils.formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build repeat selection
  Widget _buildRepeatSelection() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: _showRepeatOptions,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          children: [
            Icon(Icons.repeat, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _repeatOption,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppConstants.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment method selection
  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppConstants.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: InkWell(
            onTap: _showPaymentMethodOptions,
            borderRadius: BorderRadius.circular(30),
            child: Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(_paymentMethod),
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _paymentMethod,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build quick note section
  Widget _buildQuickNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Save Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  // Essential Helper Methods

  /// Show category selector with simple list layout
  void _showCategorySelector() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories =
        _transactionType == 'income'
            ? provider.incomeCategories
            : provider.expenseCategories;

    debugPrint('Showing category selector for $_transactionType');
    debugPrint('Available categories: ${categories.length}');
    for (var cat in categories) {
      debugPrint('  Category: ${cat.name} (${cat.type}) - ${cat.id}');
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Text(
                  'Select Category',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateCategoryDialog();
                  },
                  icon: Icon(Icons.add, color: AppConstants.primaryColor),
                  tooltip: 'Add New Category',
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              height: 450,
              child:
                  categories.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_transactionType} categories found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add one to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCreateCategoryDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add Category'),
                          ),
                        ],
                      )
                      : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategoryId == category.id;
                          return ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(
                                  FormatUtils.parseColorString(category.color),
                                ),
                                shape: BoxShape.circle,
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: AppConstants.primaryColor,
                                          width: 3,
                                        )
                                        : null,
                              ),
                              child: Icon(
                                _getIconData(category.icon),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? AppConstants.primaryColor
                                        : Colors.black87,
                              ),
                            ),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: AppConstants.primaryColor,
                                    )
                                    : null,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  /// Show create category dialog
  void _showCreateCategoryDialog() {
    _categoryNameController.clear();
    _selectedCategoryColor = Colors.blue;
    _selectedCategoryIcon = 'category';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Create Category',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Color selection
                  const Text('Choose Color'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                        ].map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border:
                                    _selectedCategoryColor == color
                                        ? Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        )
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _createCustomCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  /// Create custom category
  void _createCustomCategory() async {
    if (_categoryNameController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'Please enter a category name',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final categoryId = DateTime.now().millisecondsSinceEpoch.toString();

      final category = models.Category(
        id: categoryId,
        name: _categoryNameController.text.trim(),
        icon: _selectedCategoryIcon,
        color:
            '0x${_selectedCategoryColor.toARGB32().toRadixString(16).toUpperCase()}',
        type: _transactionType,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addCategory(category);

      if (mounted) {
        setState(() {
          _selectedCategoryId = categoryId;
        });

        Navigator.pop(context);
        CustomSnackBar.show(
          context: context,
          message: 'Category created successfully!',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to create category: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Get category name by ID
  String _getCategoryName(String categoryId) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories =
        _transactionType == 'income'
            ? provider.incomeCategories
            : provider.expenseCategories;

    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse:
          () => models.Category(
            id: '',
            name: 'Unknown Category',
            type: 'expense',
            color: 'FF006E1F',
            icon: 'category',
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
    return category.name;
  }

  /// Get or create a default account if none exists
  Future<String> _getOrCreateDefaultAccount(ExpenseProvider provider) async {
    if (provider.accounts.isNotEmpty) {
      return provider.accounts.first.id;
    }

    // Create a default account
    final defaultAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Main Account',
      type: 'cash',
      balance: 0.0,
      color: '#006E1F',
      icon: 'account_balance_wallet',
      isPrimary: true,
      description: 'Default account',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.addAccount(defaultAccount);
    return defaultAccount.id;
  }

  /// Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Save transaction
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Please select a category',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      final transaction = trans.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        accountId:
            _selectedAccountId ??
            (provider.accounts.isNotEmpty
                ? provider.accounts.first.id
                : await _getOrCreateDefaultAccount(provider)),
        type: _transactionType,
        title:
            _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : _getCategoryName(_selectedCategoryId!),
        description: _noteController.text.trim(),
        date: _selectedDate,
        tags: _paymentMethod, // Store payment method as tags
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addTransaction(transaction);

      // Add notification for the transaction
      final notificationService = context.read<NotificationService>();
      final categoryName = _getCategoryName(_selectedCategoryId!);
      final description = _noteController.text.trim();

      if (_transactionType == 'income') {
        await notificationService.addIncomeNotification(
          amount,
          description.isEmpty ? categoryName : description,
        );
      } else {
        await notificationService.addExpenseNotification(
          amount,
          categoryName,
          description.isEmpty ? categoryName : description,
        );
      }

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Transaction saved successfully!',
          type: SnackBarType.success,
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to save transaction: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get payment method icon
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Credit Card':
        return Icons.credit_card;
      case 'Debit Card':
        return Icons.credit_card_outlined;
      case 'Mobile Money':
        return Icons.phone_android;
      case 'PayPal':
        return Icons.account_balance_wallet;
      case 'Cash':
      default:
        return Icons.payments;
    }
  }

  /// Show payment method selection dialog
  void _showPaymentMethodOptions() {
    final paymentMethods = [
      {'name': 'Cash', 'icon': Icons.payments},
      {'name': 'Credit Card', 'icon': Icons.credit_card},
      {'name': 'Debit Card', 'icon': Icons.credit_card_outlined},
      {'name': 'Mobile Money', 'icon': Icons.phone_android},
      {'name': 'PayPal', 'icon': Icons.account_balance_wallet},
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Payment Method',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  paymentMethods.map((method) {
                    final isSelected = _paymentMethod == method['name'];
                    return ListTile(
                      leading: Icon(
                        method['icon'] as IconData,
                        color: AppConstants.primaryColor,
                      ),
                      title: Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? AppConstants.primaryColor
                                  : Colors.black87,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle,
                                color: AppConstants.primaryColor,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          _paymentMethod = method['name'] as String;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  /// Show repeat options dialog
  void _showRepeatOptions() {
    final repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Repeat Option',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  repeatOptions.map((option) {
                    final isSelected = _repeatOption == option;
                    return ListTile(
                      leading: Icon(
                        _getRepeatIcon(option),
                        color: AppConstants.primaryColor,
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? AppConstants.primaryColor
                                  : Colors.black87,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle,
                                color: AppConstants.primaryColor,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          _repeatOption = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  /// Get repeat option icon
  IconData _getRepeatIcon(String option) {
    switch (option) {
      case 'Never':
        return Icons.clear;
      case 'Daily':
        return Icons.today;
      case 'Weekly':
        return Icons.calendar_view_week;
      case 'Monthly':
        return Icons.calendar_view_month;
      case 'Yearly':
        return Icons.calendar_today;
      default:
        return Icons.repeat;
    }
  }

  /// Get icon data from string
  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'home': Icons.home,
      'work': Icons.work,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'category': Icons.category,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
