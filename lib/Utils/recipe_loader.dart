import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recipe.dart';

Future<List<Recipe>> loadRecipesFromJson() async {
  final String jsonString = await rootBundle.loadString('assets/data/recipes.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((json) => Recipe.fromJson(json)).toList();
}
