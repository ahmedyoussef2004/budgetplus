import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/db_helper.dart';
import '../models/expense.dart';
import '../widgets/custom_bottom_navbar.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  double totalIncome = 0.0;
  double totalSpent = 0.0;
  double remainingBalance = 0.0;
  List<Expense> expenses = [];
  Map<String, double> categoryTotals = {};
  int selectedIndex = 1;

  // ✅ Category colors for consistency
  final Map<String, Color> categoryColors = {
    'Food': Colors.teal,
    'Transport': Colors.orange,
    'Bills': Colors.blue,
    'Shopping': Colors.purple,
    'Entertainment': Colors.red,
    'Me': Colors.green,
    'House': Colors.brown,
    'Car': Colors.indigo,
    'Electronics': Colors.deepPurple,
    'Gifts': Colors.pink,
    'Family': Colors.cyan,
    'Events': Colors.amber,
    'Subscriptions': Colors.deepOrange,
    'Charity': Colors.greenAccent,
    'Loans': Colors.grey,
    'Travel': Colors.lightBlue,
  };

  @override
  void initState() {
    super.initState();
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    final prefs = await SharedPreferences.getInstance();
    totalIncome = prefs.getDouble('monthly_income') ?? 1000.0;

    expenses = await DBHelper.getExpenses();
    totalSpent = await DBHelper.getTotalExpenses();
    remainingBalance = totalIncome - totalSpent;
    _calculateCategoryTotals();
    setState(() {});
  }

  void _calculateCategoryTotals() {
    categoryTotals.clear();
    for (var expense in expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
  }

  List<PieChartSectionData> _buildPieSections() {
    return categoryTotals.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '', // Hide label in pie chart
        radius: 60,
      );
    }).toList();
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/settings');
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
      appBar: AppBar(
        title: const Text("Insights"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🧾 Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Income: £${totalIncome.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Spent: £${totalSpent.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Remaining: £${remainingBalance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Category Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            if (categoryTotals.isEmpty)
              const Expanded(child: Center(child: Text("No data to display")))
            else
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔻 Category Legend
                    Expanded(
                      child: ListView(
                        children:
                            categoryTotals.entries.map((entry) {
                              final color =
                                  categoryColors[entry.key] ?? Colors.grey;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${entry.key} - £${entry.value.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
