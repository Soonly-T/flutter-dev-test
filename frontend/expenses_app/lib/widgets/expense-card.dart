import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  const ExpenseCard({
    super.key,
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: $id',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Category: $category',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            if (notes != null && notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Notes: $notes',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}