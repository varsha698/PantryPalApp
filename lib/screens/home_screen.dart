import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/recipe.dart';
import 'matching_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController pantryController = TextEditingController();

  List<String> pantryItems = [
    "Chicken", "Beef Meat", "Octopus", "Fish", "Broccoli",
    "Egg", "Corn", "Shrimp", "Cucumber"
  ];
  Set<String> selectedPantryItems = {"Chicken"};

  List<Recipe> allRecipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipesFromCsv();
  }

  Future<void> loadRecipesFromCsv() async {
    try {
      final csvString = await rootBundle.loadString('assets/data/recipe.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

      setState(() {
        allRecipes = csvTable.skip(1).map<Recipe>((row) {
          return Recipe(
            name: row[0].toString(),
            image: 'assets/images/${row[1].toString().trim()}',
            ingredients: row[2].toString().split(','),
            steps: row[3].toString().split('.'),
            duration: row[4].toString(),
            budget: row[5].toString(),
          );
        }).toList();
      });
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Welcome,👋", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("Tasya Aulianza", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search bar
              TextField(
                controller: pantryController,
                onSubmitted: (value) {
                  String item = value.trim();
                  if (item.isNotEmpty && !pantryItems.contains(item)) {
                    setState(() {
                      pantryItems.add(item);
                      selectedPantryItems.add(item);
                      pantryController.clear();
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search Pantry Items...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pantry items
              const Text("What’s in your pantry?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pantryItems.map((item) {
                  final isSelected = selectedPantryItems.contains(item);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedPantryItems.remove(item);
                        } else {
                          selectedPantryItems.add(item);
                        }
                      });
                    },
                    child: Chip(
                      label: Text(item),
                      backgroundColor: isSelected ? Colors.orangeAccent : Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Show Recipes Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingRecipesScreen(
                          recipes: allRecipes,
                          selectedPantryItems: selectedPantryItems,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text("Show Recipes with Pantry Items"),
                ),
              ),
              const SizedBox(height: 30),

              // Low Budget Meals Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Low-Budget Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: allRecipes.take(5).map((recipe) => Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            recipe.image,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(recipe.duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pantry'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
      ),
    );
  }
}