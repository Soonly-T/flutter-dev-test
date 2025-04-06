import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/expense-card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expenseForm.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? token;
  String? username;
  String? email;
  int? userId;
  late Future<List<dynamic>?> _expensesFuture;
  double spaceHeight = 32;

  final FlutterSecureStorage storage = FlutterSecureStorage();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<int?> getUserId() async {
    final userIdString = await storage.read(key: 'id');
    return userIdString != null ? int.tryParse(userIdString) : null;
  }

  Future<String?> getUsername() async {
    final preferences = await prefs;
    return preferences.getString('username');
  }

  Future<String?> getEmail() async {
    final preferences = await prefs;
    return preferences.getString('email');
  }

  Future<void> _loadUserData() async {
    token = await getToken();
    userId = await getUserId();
    username = await getUsername();
    email = await getEmail();
  }

  Future<List<dynamic>?> getExpenses(int userId) async {
    final Uri uri = Uri.parse(
      'http://10.0.2.2:3000/expenses/get-expenses/$userId',
    );
    try {
      print('Token: $token');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
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
    var usr = await getUsername();
    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpenseForm(username: usr)),
    );

    if (newExpense == true) {
      setState(() {
        _expensesFuture = getUserId().then((id) {
          if (id != null) {
            return getExpenses(id);
          }
          return null;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _expensesFuture = Future.value([]); // Initialize with an empty Future
    _loadUserData().then((_) {
      setState(() {
        if (userId != null) {
          print("getexpenses is called");
          _expensesFuture = getExpenses(userId!);
        }
      });
    });
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _expensesFuture = getUserId().then((id) {
                  if (id != null) {
                    return getExpenses(id);
                  }
                  return null;
                });
              });
            },
          ),
        ],
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

                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(50, 50),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(0),
                        ),
                        child: Text(
                          "+",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
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
                          print(
                            "Username being passed to ExpenseCard: $username",
                          ); // Debug print
                          return ExpenseCard(
                            id: expense['ID'].toString(),
                            username: username ?? 'Loading...',
                            amount:
                                (expense['AMOUNT'] is num)
                                    ? (expense['AMOUNT'] as num).toDouble()
                                    : double.tryParse(
                                          expense['AMOUNT']?.toString() ??
                                              '0.0',
                                        ) ??
                                        0.0,
                            category: expense['CATEGORY'],
                            date: DateTime.parse(expense['DATE']),
                            notes: expense['NOTES'],
                            onExpenseUpdated: () {
                              setState(() {
                                _expensesFuture = getUserId().then((id) {
                                  if (id != null) {
                                    return getExpenses(id);
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
