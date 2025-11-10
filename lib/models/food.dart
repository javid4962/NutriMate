class Food {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final FoodCategory category;
  List<Addons> availableAddons;

  // 👇 Extended data
  final List<String>? ingredients;
  final List<String>? preparationSteps;
  final dynamic nutrition;

  Food({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddons,
    this.ingredients,
    this.preparationSteps,
    this.nutrition,
  });
}

enum FoodCategory { Tiffin, Snacks, Lunch, Dinner }

class Addons {
  String name;
  double price;

  Addons({required this.name, required this.price});
}
