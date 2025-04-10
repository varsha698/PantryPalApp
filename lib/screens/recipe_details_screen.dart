import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(recipe.image, width: double.infinity, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text("Ingredients", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.ingredients.map((i) => Text("- $i")),
            const SizedBox(height: 16),
            Text("Steps", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.steps.map((s) => Text("• $s")),
            const SizedBox(height: 16),
            Text("Duration: ${recipe.duration}"),
            Text("Budget: ${recipe.budget}"),
          ],
        ),
      ),
    );
  }
}