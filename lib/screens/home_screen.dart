import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> pantryItems = [];
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    final data = await rootBundle.loadString("assets/recipes.csv");
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    
    setState(() {
      recipes = csvTable
          .map((row) => {
                'name': row[0],
                'ingredients': row[1].split(','),
                'price': row[2],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, Tasya Aulianza")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search Pantry items...',
              ),
              onSubmitted: (value) {
                setState(() {
                  pantryItems.add(value);
                });
              },
            ),
            SizedBox(height: 16),
            Text('What’s in your pantry?'),
            Wrap(
              spacing: 8.0,
              children: pantryItems.map((item) => Chip(label: Text(item))).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic to show recipes based on pantry items
              },
              child: Text('Show Recipes with Pantry Items'),
            ),
            SizedBox(height: 16),
            Text("Low-Budget Meals"),
            // You could display low-budget meals based on recipes here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pantry'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
