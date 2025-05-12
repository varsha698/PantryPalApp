import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                recipe.image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Placeholder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 4),
                Text(recipe.duration),
                const SizedBox(width: 12),
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 4),
                Text("\$${recipe.budget.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("• ${ingredient[0].toUpperCase()}${ingredient.substring(1)}"),
                )),
            const SizedBox(height: 16),
            const Text("Steps",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("• $step"),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
