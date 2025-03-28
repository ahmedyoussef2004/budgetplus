import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'expenses.db'),
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) async {
        //add new columns when upgrading from older versions
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE expenses ADD COLUMN notes TEXT;");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE expenses ADD COLUMN subcategory TEXT;");
        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE expenses ADD COLUMN receiptPath TEXT;");
        }
      },
      onCreate: (db, version) async {
        //create the expenses table
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            subcategory TEXT,
            date TEXT,
            notes TEXT,
            receiptPath TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  //insert new expense into db
  static Future<int> insertExpense(Expense expense) async {
    final db = await getDatabase();
    int id = await db.insert('expenses', expense.toMap());

    // print("Expense Added: ${expense.toMap()}");
    return id;
  }

  //get all expenses from the db
  static Future<List<Expense>> getExpenses() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );

    // print("Expenses in DB: $maps");
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  //update an existing expense
  static Future<void> updateExpense(Expense expense) async {
    final db = await getDatabase();
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );

    // print("Expense Updated: ${expense.toMap()}");
  }

  //delete an expense by ID
  static Future<void> deleteExpense(int id) async {
    final db = await getDatabase();
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);

    // print("Expense Deleted: ID $id");
  }

  //get total sum of all expenses
  static Future<double> getTotalExpenses() async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM expenses",
    );

    double total = (result.first["total"] as double?) ?? 0.0;
    // print("Total Expenses: $total");
    return total;
  }

  //reset data
  static Future<void> clearDatabase() async {
    final db = await getDatabase();
    await db.delete('expenses');

    // print("Database Cleared");
  }
}
