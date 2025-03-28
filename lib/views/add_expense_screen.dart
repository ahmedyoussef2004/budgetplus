// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controllers/db_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Food';
  String? _selectedSubcategory;

  final List<String> categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Entertainment',
    'Me',
    'House',
    'Car',
    'Electronics',
    'Gifts',
    'Family',
    'Events',
    'Subscriptions',
    'Charity',
    'Loans',
    'Travel',
  ];

  final Map<String, List<String>> subcategoriesMap = {
    'Food': ['Groceries', 'Restaurants', 'Snacks'],
    'Transport': ['Bus', 'Train', 'Taxi'],
    'Bills': ['Electricity', 'Water', 'Internet'],
    'Shopping': ['Clothes', 'Electronics', 'Other'],
    'Entertainment': ['Movies', 'Games', 'Concerts'],
    'Me': ['Health', 'Clothes', 'Beauty'],
    'House': ['Furniture', 'Appliances', 'Repairs'],
    'Car': ['Fuel', 'Repairs', 'Insurance'],
    'Electronics': ['Phone', 'Laptop', 'Accessories'],
    'Gifts': ['Birthday', 'Wedding', 'Other'],
    'Family': ['Kids', 'Parents', 'Other'],
    'Events': ['Wedding', 'Party', 'Other'],
    'Subscriptions': ['Netflix', 'Spotify', 'Other'],
    'Charity': ['Donation', 'Fundraiser', 'Other'],
    'Loans': ['Family', 'Bank', 'Other'],
    'Travel': ['Flights', 'Hotels', 'Other'],
  };

  void saveExpense() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final newExpense = Expense(
      amount: amount,
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      date: DateTime.now().toIso8601String(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await DBHelper.insertExpense(newExpense);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: const Text("Add Expense"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "e.g. 25.50",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                    _selectedSubcategory = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Subcategory (optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                decoration: InputDecoration(
                  hintText: "Select subcategory",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    subcategoriesMap[_selectedCategory]!
                        .map(
                          (sub) =>
                              DropdownMenuItem(value: sub, child: Text(sub)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedSubcategory = val),
              ),
              const SizedBox(height: 20),
              const Text(
                "Notes (optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add some notes",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Save Expense",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
