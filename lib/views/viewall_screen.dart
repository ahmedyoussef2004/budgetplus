import 'package:flutter/material.dart';
import '../controllers/db_helper.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import 'expense_detail_screen.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final data = await DBHelper.getExpenses();
    setState(() => expenses = data);
  }

  void deleteExpense(int id) async {
    await DBHelper.deleteExpense(id);
    fetchExpenses();
  }

  void goToDetails(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: expense)),
    );
    if (result == true) fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("All Transactions"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body:
          expenses.isEmpty
              ? const Center(child: Text("No expenses available"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => goToDetails(expenses[index]),
                    child: ExpenseCard(
                      expense: expenses[index],
                      onDelete: deleteExpense,
                    ),
                  );
                },
              ),
    );
  }
}
