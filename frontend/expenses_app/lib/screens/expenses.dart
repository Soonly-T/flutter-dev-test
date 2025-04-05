import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/expense-card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expenseForm.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final storage = const FlutterSecureStorage();
  final prefs = SharedPreferences.getInstance();

  Future<String?> getUsername() async {
    final preferences = await prefs;
    return preferences.getString('username');
  }

  Future<int?> getUserId() async {
    final userIdString = await storage.read(key: 'id');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  Future<String?> getToken() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      return token;
    }
    return null;
  }

  double spaceHeight = 32;

  late Future<int?> userId;
  late Future<List<dynamic>?> _expensesFuture;
  late Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    userId = getUserId();
    _usernameFuture = getUsername();
    _expensesFuture = userId.then((id) {
      if (id != null) {
        return getExpenses(id, null, null);
      }
      return null;
    });
  }

  Future<List<dynamic>?> getExpenses(
    int userId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final Uri uri = Uri.parse('http://10.0.2.2:3000/get-expenses/$userId');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["expenses"];
      } else {
        print('Failed to get expenses: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error during HTTP request: $error');
      return null;
    }
  }

  void addExpense() async {
    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpenseForm(
              expenseData: {
                'username': getUsername(),
                'title': '',
                'amount': 0.0,
                'date': DateTime.now().toIso8601String().substring(0, 10),
                'category': '',
                'notes': '',
              },
            ),
      ),
    );

    if (newExpense == true) {
      setState(() {
        _expensesFuture = getUserId().then((id) {
          if (id != null) {
            return getExpenses(id, null, null);
          }
          return null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: spaceHeight, bottom: spaceHeight),
          child: Center(
            child: Text(
              "Your Expenses",
              style: TextStyle(
                fontSize: 32,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          addExpense();
                        },
                        child: Text(
                          "+",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(50, 50),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<dynamic>?>(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Text('No expenses found.');
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final expense = snapshot.data![index];
                          return ExpenseCard(
                            id: expense['id'].toString(),
                            username: expense['username'],
                            amount: (expense['amount'] as num).toDouble(),
                            category: expense['category'],
                            date: DateTime.parse(expense['date']),
                            notes: expense['notes'],
                            onExpenseUpdated: () {
                              setState(() {
                                _expensesFuture = getUserId().then((id) {
                                  if (id != null) {
                                    return getExpenses(id, null, null);
                                  }
                                  return null;
                                });
                              });
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
