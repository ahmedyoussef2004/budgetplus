import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/db_helper.dart';
import '../models/expense.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _incomeController = TextEditingController();
  String version = "1.0.0";

  @override
  void initState() {
    super.initState();
    _loadSavedIncome();
  }

  Future<void> _loadSavedIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final income = prefs.getDouble('monthly_income') ?? 1000.0;
    _incomeController.text = income.toStringAsFixed(2);
  }

  Future<void> _updateIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final income = double.tryParse(_incomeController.text);
    if (income != null && income > 0) {
      await prefs.setDouble('monthly_income', income);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Monthly income updated')));
      Navigator.pop(context, true);
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Reset"),
            content: const Text(
              "This will delete all your expenses. Are you sure?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await DBHelper.clearDatabase();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All expenses cleared")));
      Navigator.pop(context, true);
    }
  }

  Future<void> _exportCSV() async {
    List<Expense> expenses = await DBHelper.getExpenses();
    List<List<dynamic>> rows = [
      ['ID', 'Amount', 'Category', 'Subcategory', 'Date', 'Notes'],
      ...expenses.map(
        (e) => [
          e.id,
          e.amount,
          e.category,
          e.subcategory ?? '',
          e.date,
          e.notes ?? '',
        ],
      ),
    ];

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/expenses_export.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Exported to: $path")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Monthly Income",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter your income",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _updateIncome,
            icon: const Icon(Icons.check),
            label: const Text("Update"),
          ),
          const Divider(height: 40),

          //reset Data
          const Text(
            "Reset All Data",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.delete),
            label: const Text("Clear Expenses"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const Divider(height: 40),

          //export csv
          const Text("Export", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _exportCSV,
            icon: const Icon(Icons.download),
            label: const Text("Export as CSV"),
          ),
          const Divider(height: 40),

          //about
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Budget+ App v$version"),
          const Text("Developed by Ahmed Youssef"),
        ],
      ),
    );
  }
}
