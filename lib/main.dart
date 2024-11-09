import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExpenseScreen extends StatelessWidget {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Function to add expense to the database
  Future<void> addExpense() async {
    // Change the URL based on the device you're using
    final String url = 'http://10.0.2.2:5000/add_expense'; // Android Emulator
    // Use your machine's IP address for physical devices
    // final String url = 'http://192.168.x.x:5000/add_expense'; // Physical Device

    final response = await http.post(
      Uri.parse(url), // API URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': dateController.text.isEmpty
            ? DateTime.now().toIso8601String() // If empty, use current date
            : dateController.text,
        'category': categoryController.text,
        'description': descriptionController.text,
        'amount': double.parse(amountController.text),
      }),
    );

    if (response.statusCode == 201) {
      print('Expense added successfully');
    } else {
      print('Failed to add expense');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: addExpense,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseVisualizationScreen extends StatefulWidget {
  @override
  _ExpenseVisualizationScreenState createState() =>
      _ExpenseVisualizationScreenState();
}

class _ExpenseVisualizationScreenState extends State<ExpenseVisualizationScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Fetch Weekly Expenses Visualization
  Future<Image> fetchWeeklyExpensesImage() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:5000/visualize_weekly_expenses')); // Change to your IP

    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes); // Display the chart as an image
    } else {
      throw Exception('Failed to load chart');
    }
  }

  // Fetch Today's Expenses by Category Visualization
  Future<Image> fetchTodayExpensesByCategoryImage() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:5000/visualize_today_expenses_by_category')); // Change to your IP

    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes); // Display the chart as an image
    } else {
      throw Exception('Failed to load chart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Visualizations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Weekly Expenses'),
            Tab(text: 'Today\'s Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Weekly Expenses Visualization (Bar Chart)
          FutureBuilder<Image>(
            future: fetchWeeklyExpensesImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading chart'));
              } else if (snapshot.hasData) {
                return Center(child: snapshot.data!);
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),
          // Today's Expenses Visualization (Pie Chart)
          FutureBuilder<Image>(
            future: fetchTodayExpensesByCategoryImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading chart'));
              } else if (snapshot.hasData) {
                return Center(child: snapshot.data!);
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ExpenseVisualizationScreen(),
  ));
}
