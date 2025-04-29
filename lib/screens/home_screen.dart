import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import 'package:login_page/screens/profile_screen.dart';
import 'package:login_page/screens/community_screen.dart';
import 'package:login_page/screens/organization_screen.dart';
import 'package:login_page/screens/matching_recipes_screen.dart';
import 'package:login_page/models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController pantryController = TextEditingController();
  List<String> pantryItems = [];
  List<String> suggestions = [
    'Chicken', 'Beef Meat', 'Octopus', 'Fish', 'Broccoli',
    'Egg', 'Corn', 'Shrimp', 'Cucumber'
  ];

  List<Recipe> allRecipes = [];
  List<Recipe> matchedRecipes = [];

  String? profileImageUrl;
  String? username;

  @override
  void initState() {
    super.initState();
    loadRecipesFromCsv();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        setState(() {
          profileImageUrl = data['profileImageUrl'];
          username = data['username'] ?? user.email;
        });
      }
    }
  }

  Future<void> loadRecipesFromCsv() async {
    try {
      final csvString = await rootBundle.loadString('assets/data/recipe.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csvString);

      final recipes = csvTable.skip(1).map<Recipe>((row) {
        final ingredientsRaw = (row[2] ?? '').toString();
        final stepsRaw = (row[3] ?? '').toString();
        
        return Recipe(
          name: (row[0] ?? '').toString().trim(),
          image: 'assets/images/${(row[1] ?? '').toString().trim()}',
          ingredients: ingredientsRaw.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList(),
          steps: stepsRaw.contains('.') 
              ? stepsRaw.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
              : [stepsRaw.trim()],
          duration: (row[4] ?? '').toString(),
          budget: double.tryParse(row[5].toString()) ?? 0,
          vegan: int.tryParse(row[6].toString()) ?? 0,
          dairy: int.tryParse(row[7].toString()) ?? 0,
        );
      }).toList();

      setState(() {
        allRecipes = recipes;
        matchedRecipes = getLowBudgetMeals(recipes);
      });

      print("✅ Loaded ${recipes.length} recipes successfully!");
    } catch (e) {
      print("❌ Error loading CSV: $e");
    }
  }

  List<Recipe> getLowBudgetMeals(List<Recipe> recipes) {
    return recipes.where((r) => r.budget <= 10).toList();
  }

  void addPantryItem(String item) {
    final normalized = item.toLowerCase();
    if (item.isEmpty || pantryItems.contains(normalized)) return;
    setState(() {
      pantryItems.add(normalized);
      pantryController.clear();
    });
  }

  void toggleSuggestion(String item) {
    final normalized = item.toLowerCase();
    setState(() {
      if (pantryItems.contains(normalized)) {
        pantryItems.remove(normalized);
      } else {
        pantryItems.add(normalized);
      }
    });
  }

  List<Recipe> filterRecipes() {
    if (pantryItems.isEmpty) return [];
    return allRecipes.where((recipe) {
      return recipe.ingredients.any((ingredient) =>
          pantryItems.contains(ingredient));
    }).toList();
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return buildPantryScreen();
      case 1:
        return const CommunityScreen();
      case 2:
        return const OrganizationScreen();
      case 3:
        return const ProfileScreen();
      default:
        return buildPantryScreen();
    }
  }

  Widget buildPantryScreen() {
    return Container(
      color: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/images/profile_placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Welcome, 👋", style: TextStyle(fontSize: 12)),
              Text(
                username ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ])
          ]),
          const SizedBox(height: 16),

          TextField(
            controller: pantryController,
            onSubmitted: addPantryItem,
            decoration: InputDecoration(
              hintText: "Add Pantry Items...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => addPantryItem(pantryController.text),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          const Text("What's in your pantry?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pantryItems
                .map((item) => Chip(
                      label: Text(item),
                      deleteIcon: const Icon(Icons.cancel),
                      onDeleted: () => setState(() => pantryItems.remove(item)),
                    ))
                .toList(),
          ),

          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              final isSelected =
                  pantryItems.contains(suggestion.toLowerCase());
              return FilterChip(
                label: Text(suggestion),
                selected: isSelected,
                onSelected: (_) => toggleSuggestion(suggestion),
                selectedColor: Colors.orange.shade300,
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final filtered = filterRecipes();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchingRecipesScreen(
                    recipes: filtered,
                    selectedPantryItems: pantryItems.toSet(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text("Show Recipes with Pantry Items"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Low-Budget Meals",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("View All", style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: matchedRecipes.length,
              itemBuilder: (_, index) {
                final recipe = matchedRecipes[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: Image.asset(
                          recipe.image,
                          height: 100,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Placeholder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(recipe.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(recipe.duration,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            Text("Budget: \$${recipe.budget.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('PantryPal'),
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
