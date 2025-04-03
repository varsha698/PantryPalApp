import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/screens/profile_screen.dart';
import '../models/recipe.dart';
import '../utils/recipe_loader.dart';

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

  // 🔥 NEW: screen list
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    loadRecipes();

    _screens = [
      buildPantryScreen(),
      const Center(child: Text("Community Screen")), // Placeholder
      const Center(child: Text("Organizations Screen")), // Placeholder
      const ProfileScreen(), // ✅ Your profile page
    ];
  }

  Future<void> loadRecipes() async {
    final recipes = await loadRecipesFromJson();
    setState(() {
      allRecipes = recipes;
    });
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

  void filterRecipes() {
    if (pantryItems.isEmpty) {
      setState(() => matchedRecipes = []);
      return;
    }

    final matches = allRecipes.where((recipe) {
      int matchCount = recipe.ingredients
          .where((ingredient) => pantryItems.contains(ingredient.toLowerCase()))
          .length;
      return matchCount >= (pantryItems.length / 2).ceil();
    }).toList();

    setState(() => matchedRecipes = matches);
  }

  Widget buildPantryScreen() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      color: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Welcome, 👋", style: TextStyle(fontSize: 12)),
              Text(user?.displayName ?? user?.email ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold))
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
                      onDeleted: () =>
                          setState(() => pantryItems.remove(item)),
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
            onPressed: filterRecipes,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
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
                            Text("Budget: ${recipe.budget}",
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
      body: _screens[_selectedIndex], // ✅ Navigation now works
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pantry'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
