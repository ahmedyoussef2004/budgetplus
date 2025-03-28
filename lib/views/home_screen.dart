import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/db_helper.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'expense_detail_screen.dart';
import 'viewall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  double totalIncome = 1000.0;
  double remainingBalance = 1000.0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await _loadIncomeFromPrefs();
    fetchExpenses();
  }

  Future<void> _loadIncomeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final income = prefs.getDouble('monthly_income') ?? 1000.0;

    setState(() {
      totalIncome = income;
    });
  }

  void fetchExpenses() async {
    final expenseList = await DBHelper.getExpenses();
    double totalSpent = await DBHelper.getTotalExpenses();

    setState(() {
      expenses = expenseList;
      remainingBalance = totalIncome - totalSpent;
    });
  }

  void deleteExpense(int id) async {
    await DBHelper.deleteExpense(id);
    fetchInitialData();
  }

  void _goToDetails(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: expense)),
    );
    if (result == true) {
      fetchInitialData();
    }
  }

  void _onBottomNavTap(int index) async {
    if (index == 1) {
      final result = await Navigator.pushNamed(context, '/insights');
      if (result == true) fetchInitialData();
    } else if (index == 2) {
      final result = await Navigator.pushNamed(context, '/settings');
      if (result == true) fetchInitialData();
    }
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              const Text(
                "BUDGET+",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewAllScreen(),
                        ),
                      );
                      if (result == true) fetchInitialData();
                    },
                    child: const Text("View All"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    expenses.isEmpty
                        ? const Center(child: Text("No expenses yet."))
                        : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (ctx, i) {
                            return GestureDetector(
                              onTap: () => _goToDetails(expenses[i]),
                              child: ExpenseCard(
                                expense: expenses[i],
                                onDelete: deleteExpense,
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) fetchInitialData();
        },
        backgroundColor: Colors.black,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200,
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            "£${remainingBalance.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _incomeExpenseInfo("Income", totalIncome, Colors.white70),
              _incomeExpenseInfo(
                "Expenses",
                totalIncome - remainingBalance,
                Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _incomeExpenseInfo(String label, double amount, Color color) {
    return Row(
      children: [
        Icon(
          label == "Income" ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              "£${amount.toStringAsFixed(2)}",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
