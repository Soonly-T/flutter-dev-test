import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/alertBox.dart';

class ExpenseForm extends StatefulWidget {
  String? expenseId;
  String? username;
  String? initialNotes;
  String? initialCategory;
  double? initialAmount;

  DateTime? initialDate;

  ExpenseForm({
    this.expenseId,
    this.username,
    this.initialCategory,
    this.initialAmount,
    this.initialDate,
    this.initialNotes,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  String? token;
  String? username;
  String? email;
  int? userId;

  final FlutterSecureStorage storage = FlutterSecureStorage();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  final TextEditingController dateController = TextEditingController();

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

  Future<void> addExpense() async {
    if (token == null) {
      print('Token not found, please log in.');
      return;
    }

    // final url = Uri.parse('http://localhost:3000/expenses/add-expense');
    final url = Uri.parse('http://10.0.2.2:3000/expenses/add-expense');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Include the JWT token
    };

    final amountText = amountController.text.trim();
    final validAmountFormat = RegExp(r'^\d{1,}$|(?=^.{1,}$)^\d+\.\d{0,}$');

    if (amountText.isEmpty || !validAmountFormat.hasMatch(amountText)) {
      // Show alert for invalid amount input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid amount with at most one decimal point.',
      );
      return;
    }

    if (categoryController.text.isEmpty) {
      // Show alert for invalid category input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid category.',
      );
      return;
    }

    if (selectedDate == null) {
      // Show alert for invalid date input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please select a valid date.',
      );
      return;
    }
    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      // Show alert for invalid amount input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid positive amount.',
      );
      return;
    }
    final body = jsonEncode({
      'username': username,
      'amount': (amount * 100).round() / 100.0,
      'category': categoryController.text,
      'date': selectedDate?.toIso8601String(),
      'notes': notesController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Expense added successfully
        print('Expense added successfully');

        Navigator.pop(context, true);
      } else {
        // Error adding expense
        print('Failed to add expense: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Optionally, show an error message
      }
    } catch (error) {
      print('Error during API call: $error');
      // Optionally, show an error message
    }
  }

  Future<void> editExpense() async {
    if (token == null) {
      print('Token not found, please log in.');
      return;
    }

    // final url = Uri.parse('http://localhost:3000/expenses/add-expense');
    final url = Uri.parse('http://10.0.2.2:3000/expenses/modify-expense');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Include the JWT token
    };

    final amountText = amountController.text.trim();
    final validAmountFormat = RegExp(r'^\d{1,}$|(?=^.{1,}$)^\d+\.\d{0,}$');

    if (amountText.isEmpty || !validAmountFormat.hasMatch(amountText)) {
      // Show alert for invalid amount input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid amount with at most one decimal point.',
      );
      return;
    }

    if (categoryController.text.isEmpty) {
      // Show alert for invalid category input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid category.',
      );
      return;
    }

    if (selectedDate == null) {
      // Show alert for invalid date input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please select a valid date.',
      );
      return;
    }
    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      // Show alert for invalid amount input
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid positive amount.',
      );
      return;
    }
    print('Expense ID: ${widget.expenseId}');
    final body = jsonEncode({
      'id': widget.expenseId,
      'username': username,
      'amount': (amount * 100).round() / 100.0,
      'category': categoryController.text,
      'date': selectedDate?.toIso8601String(),
      'notes': notesController.text,
    });
    print(body);

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Expense added successfully
        print('Expense modified successfully');

        Navigator.pop(context, true);
      } else {
        // Error adding expense
        print('Failed to add expense: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Optionally, show an error message
      }
    } catch (error) {
      print('Error during API call: $error');
      // Optionally, show an error message
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with initial values
    categoryController.text = widget.initialCategory ?? '';
    amountController.text = widget.initialAmount?.toString() ?? '';
    notesController.text = widget.initialNotes ?? '';
    selectedDate =
        widget.initialDate; // Initialize selectedDate with initialDate

    // Initialize the dateController with the formatted initial date
    dateController.text =
        widget.initialDate != null
            ? "${widget.initialDate!.toLocal()}".split(' ')[0]
            : '';

    _loadUserData().then((_) {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.expenseId == null ? addExpense() : editExpense();

              // Save the expense
              // You can implement the save logic here
            },
          ),
        ],
      ),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Category'),
                controller: categoryController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                controller: amountController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Notes'),
                controller: notesController,
              ),
              GestureDetector(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(
                    selectedDate != null
                        ? "${selectedDate!.toLocal()}".split(' ')[0]
                        : 'Select a date',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate =
                          pickedDate; // Update the selectedDate state
                      dateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
