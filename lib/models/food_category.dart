import 'food_item.dart';

class FoodCategory {
  final String categoryName;
  final List<FoodItem> foodItems;

  FoodCategory({
    required this.categoryName,
    required this.foodItems,
  });
}

