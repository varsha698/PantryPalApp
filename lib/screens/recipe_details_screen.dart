import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Recipe Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Optional: Save to favorites
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                recipe.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Placeholder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔸 Title
            Text(
              recipe.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // 🔸 Quick Info Row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text("${recipe.rating}", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                const Icon(Icons.visibility, size: 16),
                const SizedBox(width: 4),
                Text("${recipe.views} views", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                const Icon(Icons.restaurant, size: 16),
                const SizedBox(width: 4),
                Text("${recipe.servings} servings", style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 20),

            // 🔸 Nutrition Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutritionBox(Icons.local_fire_department, "Calories", recipe.calories),
                _buildNutritionBox(Icons.fitness_center, "Protein", recipe.protein),
                _buildNutritionBox(Icons.restaurant_menu, "Carbs", recipe.carbs),
              ],
            ),

            const SizedBox(height: 24),

            // 🔸 Ingredients
            const Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ingredient)),
                  ],
                )),

            const SizedBox(height: 24),

            // 🔸 Steps
            const Text("Cooking Steps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(recipe.steps.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(recipe.steps[index])),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBox(IconData icon, String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.orange),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
