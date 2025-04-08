class Recipe {
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final String duration;
  final String budget;

  Recipe({
    required this.name,
    required this.image,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.budget,
  });
}