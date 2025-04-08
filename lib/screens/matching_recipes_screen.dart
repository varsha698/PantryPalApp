import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';

class MatchingRecipesScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> selectedPantryItems;

  const MatchingRecipesScreen({
    super.key,
    required this.recipes,
    required this.selectedPantryItems,
  });

  int matchedCount(List<String> ingredients) {
    return ingredients.where((item) => selectedPantryItems.contains(item.trim())).length;
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Filter out recipes with no matches
    List<Recipe> filtered = recipes.where((recipe) {
      return matchedCount(recipe.ingredients) > 0;
    }).toList();

    // Step 2: Sort by number of matches (descending)
    filtered.sort((a, b) {
      int aMatch = matchedCount(a.ingredients);
      int bMatch = matchedCount(b.ingredients);
      return bMatch.compareTo(aMatch); // Most matched at top
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        title: const Text("Matching Recipes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filtered.isEmpty
            ? const Center(child: Text("No matching recipes found."))
            : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  final match = matchedCount(recipe.ingredients);
                  final total = recipe.ingredients.length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            recipe.image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipe.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                "$match / $total ingredients match",
                                style: TextStyle(
                                  color: match >= total / 2
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 4),
                                  Text(recipe.duration),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.attach_money, size: 16),
                                  const SizedBox(width: 4),
                                  Text("\$${recipe.budget}"),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailsScreen(recipe: recipe),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("View Recipe"),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}