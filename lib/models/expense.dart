import 'package:flutter/material.dart';

// expense properties
class Expense {
  final int? id;
  final double amount;
  final String category;
  final String? subcategory;
  final String date;
  final String? notes;
  final String? receiptPath;

  // create a new expense instance
  Expense({
    this.id,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.date,
    this.notes,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'subcategory': subcategory,
      'date': date,
      'notes': notes,
      'receiptPath': receiptPath,
    };
  }

  //create an expense object from a map
  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      subcategory: map['subcategory'],
      date: map['date'],
      notes: map['notes'],
      receiptPath: map['receiptPath'], // ✅ Load from DB
    );
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt_long;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Me':
        return Icons.self_improvement;
      case 'House':
        return Icons.home;
      case 'Car':
        return Icons.directions_car_filled;
      case 'Electronics':
        return Icons.devices;
      case 'Gifts':
        return Icons.card_giftcard;
      case 'Family':
        return Icons.family_restroom;
      case 'Events':
        return Icons.event;
      case 'Subscriptions':
        return Icons.subscriptions;
      case 'Charity':
        return Icons.volunteer_activism;
      case 'Loans':
        return Icons.request_quote;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.attach_money;
    }
  }
}
