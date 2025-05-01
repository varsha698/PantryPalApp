import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';

class MatchingRecipesScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final Set<String> selectedPantryItems;

  const MatchingRecipesScreen({
    super.key,
    required this.recipes,
    required this.selectedPantryItems,
  });

  @override
  State<MatchingRecipesScreen> createState() => _MatchingRecipesScreenState();
}

class _MatchingRecipesScreenState extends State<MatchingRecipesScreen> {
  int maxTime = 60;
  double maxBudget = 15;
  bool veganOnly = false;
  bool dairyFreeOnly = false;

  int matchedCount(List<String> ingredients) {
    return ingredients
        .where((item) => widget.selectedPantryItems.contains(item.trim()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    List<Recipe> filtered = widget.recipes.where((recipe) {
      int durationMinutes = int.tryParse(recipe.duration.split(' ').first) ?? 0;
      double recipeBudget = recipe.budget;

      bool matchesVegan = !veganOnly || recipe.vegan == 1;
      bool matchesDairyFree = !dairyFreeOnly || recipe.dairy == 0;

      return matchedCount(recipe.ingredients) > 0 &&
          durationMinutes <= maxTime &&
          recipeBudget <= maxBudget &&
          matchesVegan &&
          matchesDairyFree;
    }).toList();

    filtered.sort((a, b) =>
        matchedCount(b.ingredients).compareTo(matchedCount(a.ingredients)));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        title: const Text("Matching Recipes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        label: "Max Time: $maxTime min",
                        value: maxTime.toDouble(),
                        min: 10,
                        max: 60,
                        divisions: 5,
                        onChanged: (value) =>
                            setState(() => maxTime = value.toInt()),
                      ),
                    ),
                    Text("$maxTime min"),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        label: "Max Budget: \$$maxBudget",
                        value: maxBudget,
                        min: 5,
                        max: 15,
                        divisions: 10,
                        onChanged: (value) =>
                            setState(() => maxBudget = value),
                      ),
                    ),
                    Text("\$${maxBudget.toStringAsFixed(0)}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Vegan Only"),
                    Switch(
                      value: veganOnly,
                      onChanged: (value) =>
                          setState(() => veganOnly = value),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dairy-Free Only"),
                    Switch(
                      value: dairyFreeOnly,
                      onChanged: (value) =>
                          setState(() => dairyFreeOnly = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No matching recipes found."))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      final match = matchedCount(recipe.ingredients);
                      final total = recipe.ingredients.length;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                errorBuilder: (_, __, ___) =>
                                    const Placeholder(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipe.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
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
                                      Text(
                                        "\$${recipe.budget.toStringAsFixed(2)}",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailsScreen(recipe: recipe),
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}
