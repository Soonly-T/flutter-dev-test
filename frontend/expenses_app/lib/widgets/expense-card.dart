import 'package:expenses_app/screens/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/expenseForm.dart';

class ExpenseCard extends StatelessWidget {
  final String id;
  final double amount;
  final String username;
  final String category;
  final DateTime date;
  final String? notes;

  ExpenseCard({
    super.key,
    required this.id,
    required this.username,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  final storage = FlutterSecureStorage();
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<int?> getUserId() async {
    final userIdString = await storage.read(key: 'id');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  Future<String?> getUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('username'); // Retrieve the stored username
  }

  Future<String?> getToken() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      return token;
    }
    return null;
  }

  void deleteExpense(BuildContext context) async {
    final url = Uri.parse('https://10.0.2.2:3000/expenses/remove-expense');
    final token = await getToken(); // Get the token

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token
        },
        body: {'id': id, 'username': username},
      );

      if (response.statusCode == 200) {
        print('Expense deleted successfully');
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ExpensesScreen()),
          );
        }
      } else {
        print('Failed to delete expense: ${response.body}');
      }
    } catch (error) {
      print('Error deleting expense: $error');
    }
  }

  void editExpense(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpenseForm(
              expenseData: {
                'id': id,
                'username': username,
                'amount': amount,
                'category': category,
                'date': date.toIso8601String(),
                'notes': notes,
              },
            ),
      ),
    );

    if (result == true) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpensesScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: $id',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: ElevatedButton(
                          onPressed: () => editExpense(context),
                          child: Container(
                            child: Icon(
                              Icons.edit, // Use an icon for better alignment
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(35, 35),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: ElevatedButton(
                          onPressed:
                              () => deleteExpense(
                                context,
                              ), // Call the delete function
                          child: Icon(
                            Icons.remove, // Use an icon for better alignment
                            color: Colors.white,
                            size: 20,
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(35, 35),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.all(0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Amount: \$${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('Category: $category', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                'Date: ${date.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16),
              ),
              if (notes != null && notes!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'Notes: $notes',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
