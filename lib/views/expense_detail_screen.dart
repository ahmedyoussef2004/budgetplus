import 'dart:io';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(expense.date);
    final formattedDate = "${date.day}/${date.month}/${date.year}";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Expense Details"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),

            _buildLabel("Category"),
            const SizedBox(height: 6),
            Text(expense.category, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),
            _buildLabel("Subcategory"),
            const SizedBox(height: 6),
            Text(
              expense.subcategory?.isNotEmpty == true
                  ? expense.subcategory!
                  : "Not specified",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),
            _buildLabel("Date"),
            const SizedBox(height: 6),
            Text(formattedDate, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),
            _buildLabel("Notes"),
            const SizedBox(height: 6),
            Text(
              expense.notes?.isNotEmpty == true
                  ? expense.notes!
                  : "No notes added.",
              style: const TextStyle(fontSize: 18),
            ),

            if (expense.receiptPath != null &&
                expense.receiptPath!.isNotEmpty &&
                File(expense.receiptPath!).existsSync()) ...[
              const SizedBox(height: 20),
              _buildLabel("Receipt"),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(expense.receiptPath!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 30),

            // ✏️ Edit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditExpenseScreen(expense: expense),
                    ),
                  ).then((value) {
                    if (value == true) {
                      Navigator.pop(context, true); // Refresh on return
                    }
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Amount",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            "£${expense.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
