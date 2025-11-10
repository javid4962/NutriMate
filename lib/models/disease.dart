import 'food.dart';

class Disease {
  final String name;
  final String description;
  final List<FoodCategory> categories;
  final List<String> restrictedFoods;

  Disease({
    required this.name,
    required this.description,
    required this.categories,
    required this.restrictedFoods,
  });
}
