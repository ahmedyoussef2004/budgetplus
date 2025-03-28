import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Function onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onDelete});

  String getFormattedDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('EEE, MMM d, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String getFormattedAmount(double amount) {
    return "£${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText =
        expense.subcategory != null && expense.subcategory!.isNotEmpty
            ? "${expense.category} > ${expense.subcategory} - ${getFormattedDate(expense.date)}"
            : "${expense.category} - ${getFormattedDate(expense.date)}";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.teal[100],
          child: Icon(
            Expense.getCategoryIcon(expense.category),
            size: 28,
            color: Colors.teal[700],
          ),
        ),
        title: Text(
          getFormattedAmount(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitleText,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDelete(expense.id!),
        ),
      ),
    );
  }
}
