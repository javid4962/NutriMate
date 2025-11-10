
import 'disease_models_and_mock_data.dart';
import 'food.dart';

/// ✅ Converts [FoodItemModel] → your existing [Food] model
extension FoodMapper on FoodItemModel {
  Food toFood() {
    return Food(
      name: name,
      description: description,
      imagePath: imagePath ?? "assets/images/default_food.png",
      price: price,
      category: _mapFoodTypeToCategory(type),
      availableAddons: _generateAddons(),

      // 👇 include these new fields
      ingredients: ingredients,
      preparationSteps: preparationSteps,
      nutrition: nutrition,
    );
  }


  /// Convert FoodType enum (from disease model) → FoodCategory enum (from your app)
  FoodCategory _mapFoodTypeToCategory(FoodType type) {
    switch (type) {
      case FoodType.tiffin:
        return FoodCategory.Tiffin;
      case FoodType.snacks:
        return FoodCategory.Snacks;
      case FoodType.lunch:
        return FoodCategory.Lunch;
      case FoodType.dinner:
        return FoodCategory.Dinner;
    }
  }

  /// Generate Addons dynamically or keep empty (for now)
  List<Addons> _generateAddons() {
    // For demo — you can later customize this per disease
    return [
      Addons(name: "Extra Salad", price: 20.0),
      Addons(name: "Low Fat Curd", price: 15.0),
    ];
  }
}

/// ✅ Converts [DiseaseModel] → list of [Food] items (flattened)
extension DiseaseToFoodList on DiseaseModel {
  List<Food> get asFoodList => allFoodItems.map((item) => item.toFood()).toList();
}
