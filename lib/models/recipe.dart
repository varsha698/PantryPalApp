class Recipe {
  final String name;
  final List<String> ingredients;
  final String duration;
  final String image;
  final String steps;
  final String budget;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.duration,
    required this.image,
    required this.steps,
    required this.budget,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      duration: json['duration'],
      image: json['image'],
      steps: json['steps'],
      budget: json['budget'],
    );
  }
}
