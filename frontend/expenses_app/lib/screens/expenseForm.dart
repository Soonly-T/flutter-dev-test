import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExpenseForm extends StatefulWidget {
  final Map<String, dynamic> expenseData;

  const ExpenseForm({Key? key, required this.expenseData}) : super(key: key);

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;
  final _storage =
      const FlutterSecureStorage(); // Instance of FlutterSecureStorage

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.expenseData['title'] ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expenseData['amount']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.expenseData['date'] ?? '',
    );
    if (widget.expenseData['date'] != null &&
        widget.expenseData['date'].isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.expenseData['date']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toIso8601String().substring(
          0,
          10,
        ); // Format as YYYY-MM-DD
      });
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final isAdding = widget.expenseData['id'] == null;
      final url =
          isAdding
              ? Uri.parse('http://10.0.2.2:3000/expenses/add-expense')
              : Uri.parse('http://10.0.2.2:3000/expenses/update-expense');

      final body =
          isAdding
              ? {
                'username': widget.expenseData['username'],
                'amount': double.parse(_amountController.text),
                'category': widget.expenseData['category'],
                'date': _selectedDate?.toIso8601String(),
                'notes': widget.expenseData['notes'],
              }
              : {
                'id': widget.expenseData['id'],
                'username': widget.expenseData['username'],
                'amount': double.parse(_amountController.text),
                'category': widget.expenseData['category'],
                'date': _selectedDate?.toIso8601String(),
                'notes': widget.expenseData['notes'],
              };

      final token = await _storage.read(key: 'token'); // Retrieve the token

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Add the token to the header
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Expense saved successfully');
          Navigator.pop(context, true); // Indicate success
        } else {
          print('Failed to save expense: ${response.body}');
          // Optionally show an error message to the user
        }
      } catch (e) {
        print('Error occurred: $e');
        // Optionally show an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expenseData['id'] == null ? 'Add Expense' : 'Edit Expense',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // Prevent manual editing
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
