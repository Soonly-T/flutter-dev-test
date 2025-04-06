import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/expense-card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './login.dart';
import 'package:expenses_app/main.dart';

import 'expenseForm.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

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
  DateTime? _selectedDate;
  List<dynamic> _allExpenses = []; // To store all fetched expenses

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

  Future<List<dynamic>?> getExpenses() async {
    final uri =
        Uri.parse('http://$frontendHost:$frontendPort/expenses/get-expenses');
    try {
      debugPrint('Token: $token');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('All Expenses Response: ${response.body}');
        final responseData = jsonDecode(response.body);
        _allExpenses = responseData["expenses"] ?? [];
        return _filterExpensesByMonthYear(_selectedDate);
      } else {
        debugPrint('Failed to get expenses: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error during HTTP request: $error');
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
      _refreshExpenses();
    }
  }

  Future<void> _refreshExpenses() async {
    setState(() {
      _expensesFuture = getExpenses();
    });
  }

  List<dynamic> _filterExpensesByMonthYear(DateTime? date) {
    if (date == null) {
      return _allExpenses;
    }
    final year = date.year;
    final month = date.month;
    return _allExpenses.where((expense) {
      final expenseDate = DateTime.parse(expense['DATE']);
      return expenseDate.year == year && expenseDate.month == month;
    }).toList();
  }

  Future<void> _showMonthYearPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 1), // Adjust as needed
      initialDatePickerMode: DatePickerMode.year,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              accentColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month);
        _expensesFuture =
            Future.value(_filterExpensesByMonthYear(_selectedDate));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _expensesFuture = getExpenses(); // Fetch all expenses on init
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _showMonthYearPicker,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8),
                            Text(
                              _selectedDate != null
                                  ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}"
                                  : "Filter by Month and Year",
                            ),
                          ],
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
                      return const Text(
                          'No expenses found for the selected month.');
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final expense = snapshot.data![index];
                          debugPrint(
                            "Username being passed to ExpenseCard: $username",
                          ); // Debug debugPrint
                          return ExpenseCard(
                            id: expense['ID'].toString(),
                            username: username ?? 'Loading...',
                            amount: (expense['AMOUNT'] is num)
                                ? (expense['AMOUNT'] as num).toDouble()
                                : double.tryParse(
                                      expense['AMOUNT']?.toString() ?? '0.0',
                                    ) ??
                                    0.0,
                            category: expense['CATEGORY'],
                            date: DateTime.parse(expense['DATE']),
                            notes: expense['NOTES'],
                            onExpenseUpdated: () {
                              _refreshExpenses();
                            },
                          );
                        },
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _refreshExpenses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Refresh"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final storage = FlutterSecureStorage();
                          final prefs = await SharedPreferences.getInstance();

                          await storage.delete(key: 'token');
                          await storage.delete(key: 'id');
                          await prefs.remove('username');
                          await prefs.remove('email');

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
