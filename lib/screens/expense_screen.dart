import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/expense_provider.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Groceries';

  final List<String> _categories = [
    'Groceries',
    'Utilities',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Shopping',
    'Food & Dining',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics, color: Colors.blue.shade700, size: 28),
            SizedBox(width: 10),
            Text(
              'Expense Tracker',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return Column(
            children: [
              _buildSummaryCards(expenseProvider),
              _buildCategoryChart(expenseProvider),
              Expanded(child: _buildExpensesList(expenseProvider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade600,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Expense', style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddExpenseDialog(),
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    'Total',
                    '\$${provider.totalExpenses.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                  _buildStatColumn(
                    'This Month',
                    '\$${provider.monthlyTotal.toStringAsFixed(2)}',
                    Icons.calendar_month,
                    Colors.green,
                  ),
                  _buildStatColumn(
                    'Records',
                    '${provider.expenses.length}',
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(ExpenseProvider provider) {
    final categoryTotals = provider.categoryTotals;
    if (categoryTotals.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...categoryTotals.entries.map((entry) {
                final percentage = (entry.value / provider.totalExpenses) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(entry.key)),
                      Expanded(
                        flex: 5,
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No expenses recorded yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: provider.expenses.length,
        itemBuilder: (context, index) {
          final expense =
              provider.expenses[provider.expenses.length - 1 - index];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.receipt, color: Colors.blue.shade600),
              ),
              title: Text(
                expense.title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
              ),
              trailing: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade600,
                ),
              ),
              onLongPress: () =>
                  _showDeleteExpenseDialog(expense.id, expense.title),
            ),
          );
        },
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.blue.shade600),
                  SizedBox(width: 8),
                  Text('Add Expense'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _amountController.text.isNotEmpty) {
                      final amount = double.tryParse(_amountController.text);
                      if (amount != null) {
                        context.read<ExpenseProvider>().addExpense(
                          _titleController.text,
                          amount,
                          _selectedCategory,
                        );
                        _titleController.clear();
                        _amountController.clear();
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteExpenseDialog(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('Delete Expense'),
          ],
        ),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<ExpenseProvider>().deleteExpense(id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
