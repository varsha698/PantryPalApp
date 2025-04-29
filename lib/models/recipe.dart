class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String image;
  final String duration;
  final double budget;
  final int vegan; // 1 = vegan, 0 = not vegan
  final int dairy; // 1 = contains dairy, 0 = dairy-free

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.image,
    required this.duration,
    required this.budget,
    required this.vegan,
    required this.dairy,
  });
}
