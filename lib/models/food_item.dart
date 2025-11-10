import 'nutrition_info.dart';

class FoodItem {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final List<String> ingredients;
  final List<String> preparationSteps;
  final NutritionInfo nutrition;

  FoodItem({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.ingredients,
    required this.preparationSteps,
    required this.nutrition,
  });
}
