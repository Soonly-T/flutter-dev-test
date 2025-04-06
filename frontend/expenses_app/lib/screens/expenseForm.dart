import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/alertBox.dart';
import 'package:expenses_app/main.dart';

class ExpenseForm extends StatefulWidget {
  String? expenseId;
  String? username; // You might still need this for UI display
  String? initialNotes;
  String? initialCategory;
  double? initialAmount;

  DateTime? initialDate;

  ExpenseForm({
    super.key,
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
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  final TextEditingController dateController = TextEditingController();

  // New state for dropdown and "Others" text field
  String? selectedCategory;
  final TextEditingController othersCategoryController =
      TextEditingController();
  bool showOthersTextField = false;

  // List of common expense categories
  final List<String> categories = [
    'Food',
    'Transportation',
    'Utilities',
    'Rent',
    'Entertainment',
    'Shopping',
    'Health',
    'Travel',
    'Education',
    'Personal Care',
    'Others',
  ];

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
      debugPrint('Token not found, please log in.');
      return;
    }
    final url = Uri.parse(
      'http://$frontendHost:$frontendPort/expenses/add-expense',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final amountText = amountController.text.trim();
    final validAmountFormat = RegExp(r'^\d{1,}$|(?=^.{1,}$)^\d+\.\d{0,}$');

    if (amountText.isEmpty || !validAmountFormat.hasMatch(amountText)) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid amount with at most one decimal point.',
      );
      return;
    }

    String categoryToSend = selectedCategory == 'Others'
        ? othersCategoryController.text
        : selectedCategory ?? '';

    if (categoryToSend.isEmpty) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid category.',
      );
      return;
    }

    if (selectedDate == null) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please select a valid date.',
      );
      return;
    }
    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid positive amount.',
      );
      return;
    }
    final body = jsonEncode({
      'userId': userId, // Use userId instead of username
      'amount': (amount * 100).round() / 100.0,
      'category': categoryToSend,
      'date': selectedDate?.toIso8601String(),
      'notes': notesController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Expense added successfully');
        Navigator.pop(context, true);
      } else {
        debugPrint('Failed to add expense: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error during API call: $error');
    }
  }

  Future<void> editExpense() async {
    // ... (rest of the editExpense function remains largely the same, just update categoryToSend logic)
    if (token == null) {
      debugPrint('Token not found, please log in.');
      return;
    }
    final url = Uri.parse(
      'http://$frontendHost:$frontendPort/expenses/modify-expense',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final amountText = amountController.text.trim();
    final validAmountFormat = RegExp(r'^\d{1,}$|(?=^.{1,}$)^\d+\.\d{0,}$');

    if (amountText.isEmpty || !validAmountFormat.hasMatch(amountText)) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid amount with at most one decimal point.',
      );
      return;
    }

    String categoryToSend = selectedCategory == 'Others'
        ? othersCategoryController.text
        : selectedCategory ?? '';

    if (categoryToSend.isEmpty) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid category.',
      );
      return;
    }

    if (selectedDate == null) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please select a valid date.',
      );
      return;
    }
    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      alertBox.showAlertDialog(
        context,
        'Invalid Input',
        'Please enter a valid positive amount.',
      );
      return;
    }
    debugPrint('Expense ID: ${widget.expenseId}');
    final body = jsonEncode({
      'id': widget.expenseId,
      'userId': userId, // Use userId instead of username
      'amount': (amount * 100).round() / 100.0,
      'category': categoryToSend,
      'date': selectedDate?.toIso8601String(),
      'notes': notesController.text,
    });
    debugPrint(body);

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Expense modified successfully');
        Navigator.pop(context, true);
      } else {
        debugPrint('Failed to add expense: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error during API call: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with initial values
    amountController.text = widget.initialAmount?.toString() ?? '';
    notesController.text = widget.initialNotes ?? '';
    selectedDate = widget.initialDate;

    dateController.text = widget.initialDate != null
        ? "${widget.initialDate!.toLocal()}".split(' ')[0]
        : '';

    // Initialize selectedCategory and "Others" text field visibility
    selectedCategory = widget.initialCategory;
    if (widget.initialCategory != null &&
        !categories.contains(widget.initialCategory)) {
      selectedCategory = 'Others';
      othersCategoryController.text = widget.initialCategory!;
      showOthersTextField = true;
    } else {
      showOthersTextField = selectedCategory == 'Others';
    }

    _loadUserData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: selectedCategory,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      showOthersTextField = newValue == 'Others';
                    });
                  },
                ),
                if (showOthersTextField)
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Other Category'),
                    controller: othersCategoryController,
                  ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                        selectedDate = pickedDate;
                        dateController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.expenseId == null ? addExpense() : editExpense();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
