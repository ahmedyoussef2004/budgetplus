import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../controllers/db_helper.dart';
import '../models/expense.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String _selectedCategory = 'Food';
  String? _selectedSubcategory;
  // ignore: unused_field
  File? _receiptImage;
  String? _existingReceiptPath;

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

  final Map<String, List<String>> subcategoryMap = {
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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: widget.expense.notes ?? '');
    _selectedCategory = widget.expense.category;
    _existingReceiptPath = widget.expense.receiptPath;

    final validSubs = subcategoryMap[_selectedCategory] ?? [];
    if (validSubs.contains(widget.expense.subcategory)) {
      _selectedSubcategory = widget.expense.subcategory;
    } else {
      _selectedSubcategory = null;
    }
  }

  String formatDate(String raw) {
    try {
      DateTime parsed = DateTime.parse(raw);
      return DateFormat('EEE, MMM d, yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          "receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}";
      final savedImage = await File(picked.path).copy('${dir.path}/$fileName');

      setState(() {
        _receiptImage = savedImage;
        _existingReceiptPath = savedImage.path;
      });
    }
  }

  void saveExpense() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final updatedExpense = Expense(
      id: widget.expense.id,
      amount: amount,
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      date: widget.expense.date,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      receiptPath: _existingReceiptPath,
    );

    await DBHelper.updateExpense(updatedExpense);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableSubcategories = subcategoryMap[_selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildLabel("Amount"),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Enter amount"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Category"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration("Choose category"),
              items:
                  categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
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
            _buildLabel("Subcategory"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value:
                  availableSubcategories.contains(_selectedSubcategory)
                      ? _selectedSubcategory
                      : null,
              decoration: _inputDecoration("Choose subcategory"),
              items:
                  availableSubcategories
                      .map(
                        (sub) => DropdownMenuItem(value: sub, child: Text(sub)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedSubcategory = val;
                });
              },
            ),

            const SizedBox(height: 20),
            _buildLabel("Notes"),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: _inputDecoration("Optional note"),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            _buildLabel("Receipt"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Upload"),
                ),
              ],
            ),

            if (_existingReceiptPath != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_existingReceiptPath!), height: 180),
              ),
            ],

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Date: ${formatDate(widget.expense.date)}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saveExpense,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
