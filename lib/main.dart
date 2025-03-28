import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense.dart';
import 'views/add_expense_screen.dart';
import 'views/edit_expense_screen.dart';
import 'views/expense_detail_screen.dart';
import 'views/home_screen.dart';
import 'views/insights_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/settings_screen.dart';
import 'views/setup_screen.dart';
import 'views/viewall_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final setupComplete = prefs.getBool('setupComplete') ?? false;

  runApp(MyApp(seenOnboarding: seenOnboarding, setupComplete: setupComplete));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  final bool setupComplete;

  const MyApp({
    super.key,
    required this.seenOnboarding,
    required this.setupComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Budgeting App",
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      initialRoute:
          !seenOnboarding ? '/' : (!setupComplete ? '/setup' : '/home'),
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/setup': (context) => const SetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddExpenseScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/viewall': (context) => const ViewAllScreen(),
        '/details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Expense;
          return ExpenseDetailScreen(expense: args);
        },
        '/edit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Expense;
          return EditExpenseScreen(expense: args);
        },
      },
    );
  }
}
