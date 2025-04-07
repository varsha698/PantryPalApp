class Recipe {
  final String name;
  final List<String> ingredients;
  final String duration;
  final String image;
  final List<String> steps;
  final String budget;

  // ✅ NEW FIELDS
  final double rating;
  final int views;
  final int servings;
  final String calories;
  final String protein;
  final String carbs;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.duration,
    required this.image,
    required this.steps,
    required this.budget,
    required this.rating,
    required this.views,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      duration: json['duration'],
      image: json['image'],
      steps: List<String>.from(json['steps']),
      budget: json['budget'],

      // ✅ NEW FIELDS from updated JSON
      rating: (json['rating'] as num).toDouble(),
      views: json['views'] as int,
      servings: json['servings'] as int,
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
    );
  }
}
