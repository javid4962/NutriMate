
import 'package:flutter/foundation.dart';

enum FoodType { tiffin, lunch, dinner, snacks }

class NutritionInfo {
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double calories; // kcal

  const NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'calories': calories,
  };

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
    protein: (json['protein'] ?? 0).toDouble(),
    carbs: (json['carbs'] ?? 0).toDouble(),
    fat: (json['fat'] ?? 0).toDouble(),
    calories: (json['calories'] ?? 0).toDouble(),
  );
}

class FoodItemModel {
  final String id; // unique id
  final String name;
  final String description;
  final String? imagePath; // local asset path or network URL
  final double price;
  final FoodType type;
  final List<String> ingredients; // ingredient list
  final List<String> preparationSteps; // step-by-step
  final NutritionInfo? nutrition;

  FoodItemModel({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    required this.price,
    required this.type,
    required this.ingredients,
    required this.preparationSteps,
    this.nutrition,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'price': price,
    'type': describeEnum(type),
    'ingredients': ingredients,
    'preparationSteps': preparationSteps,
    'nutrition': nutrition?.toJson(),
  };

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
    id: json['id'] ?? UniqueKey().toString(),
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    imagePath: json['imagePath'],
    price: (json['price'] ?? 0).toDouble(),
    type: FoodType.values.firstWhere(
            (e) => describeEnum(e) == (json['type'] ?? 'lunch'),
        orElse: () => FoodType.lunch),
    ingredients: List<String>.from(json['ingredients'] ?? []),
    preparationSteps: List<String>.from(json['preparationSteps'] ?? []),
    nutrition: json['nutrition'] != null
        ? NutritionInfo.fromJson(Map<String, dynamic>.from(json['nutrition']))
        : null,
  );
}

class FoodCategoryModel {
  final FoodType type;
  final String title; // e.g., "Tiffin", "Lunch"
  final List<FoodItemModel> items;

  FoodCategoryModel({
    required this.type,
    required this.title,
    required this.items,
  });
}

class DiseaseModel {
  final String id;
  final String name;
  final String shortDescription;
  final String longDescription;
  final List<String> restrictedFoods; // foods to avoid
  final List<FoodCategoryModel> categories;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.restrictedFoods,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortDescription': shortDescription,
    'longDescription': longDescription,
    'restrictedFoods': restrictedFoods,
    'categories': categories
        .map((c) => {
      'type': describeEnum(c.type),
      'title': c.title,
      'items': c.items.map((i) => i.toJson()).toList(),
    })
        .toList(),
  };

  // Convenience: find all food items across categories
  List<FoodItemModel> get allFoodItems => categories.expand((c) => c.items).toList();
}


// ------------------ MOCK DATA ------------------

// Helper to create unique ids quickly in examples
String _mkId(String prefix) => '${prefix}_${DateTime.now().millisecondsSinceEpoch}';

final DiseaseModel diabetesDisease = DiseaseModel(
  id: 'disease_diabetes',
  name: 'Diabetes (Type 2)',
  shortDescription:
  'A metabolic disorder characterized by high blood glucose; focus on low-GI, high-fiber meals.',
  longDescription:
  'Diabetes management diet aims to stabilize blood glucose, provide adequate protein and micronutrients, and avoid rapid glycemic spikes. Prefer whole grains, millets, legumes, vegetables and lean proteins.',
  restrictedFoods: ['Sugar', 'Sweets', 'White Rice', 'Deep fried foods', 'Sugary beverages'],
  categories: [
    FoodCategoryModel(
      type: FoodType.tiffin,
      title: 'Tiffin',
      items: [
        FoodItemModel(
          id: 'diab_tiffin_oats_upma',
          name: 'Vegetable Oats Upma',
          description: 'Low-GI savory oats cooked with mixed vegetables and mild spices.',
          imagePath: 'assets/images/diabetes/oats_upma.png',
          price: 70.0,
          type: FoodType.tiffin,
          ingredients: [
            'Rolled oats - 1 cup',
            'Mixed vegetables (carrot, beans, peas) - 1/2 cup',
            'Mustard seeds - 1/2 tsp',
            'Green chillies - 1 (optional)',
            'Olive oil - 1 tsp',
            'Salt - to taste',
          ],
          preparationSteps: [
            'Dry roast oats for 2 minutes and keep aside.',
            'Heat oil, add mustard seeds and curry leaves.',
            'Saute vegetables until slightly soft.',
            'Add oats and water (1:2 ratio), cover and cook until done.',
            'Finish with lemon juice and coriander.',
          ],
          nutrition: const NutritionInfo(protein: 8, carbs: 30, fat: 4, calories: 200),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.lunch,
      title: 'Lunch',
      items: [
        FoodItemModel(
          id: 'diab_lunch_brown_rice_thali',
          name: 'Brown Rice Thali',
          description: 'Brown rice with dal, mixed vegetable sabzi and salad.',
          imagePath: 'assets/images/diabetes/brown_rice_thali.png',
          price: 130.0,
          type: FoodType.lunch,
          ingredients: [
            'Brown rice - 1 cup',
            'Toor dal - 1/2 cup',
            'Mixed vegetables - 1 cup',
            'Turmeric, salt, cumin',
            'Olive oil - 1 tsp',
          ],
          preparationSteps: [
            'Cook brown rice in a rice cooker.',
            'Pressure cook dal with turmeric and salt.',
            'Saute vegetables with cumin and minimal oil.',
            'Assemble thali and add fresh salad on side.',
          ],
          nutrition: const NutritionInfo(protein: 12, carbs: 60, fat: 6, calories: 360),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.dinner,
      title: 'Dinner',
      items: [
        FoodItemModel(
          id: 'diab_dinner_millet_roti_paneer',
          name: 'Finger Millet Roti + Paneer Sabzi',
          description: 'Millet-based rotis served with a light paneer gravy.',
          imagePath: 'assets/images/diabetes/millet_roti_paneer.png',
          price: 120.0,
          type: FoodType.dinner,
          ingredients: [
            'Finger millet flour - 1 cup',
            'Paneer - 100g',
            'Tomato, onion, spices',
            'Olive oil - 1 tsp',
          ],
          preparationSteps: [
            'Make dough with millet flour and water; roll and cook rotis.',
            'Prepare paneer gravy using tomatoes, onions and mild spices.',
            'Serve 2 rotis with 1/2 cup paneer sabzi and salad.',
          ],
          nutrition: const NutritionInfo(protein: 18, carbs: 40, fat: 10, calories: 380),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.snacks,
      title: 'Snacks',
      items: [
        FoodItemModel(
          id: 'diab_snack_roasted_chana',
          name: 'Roasted Chana & Buttermilk',
          description: 'Protein-rich roasted chana paired with spiced buttermilk.',
          imagePath: 'assets/images/diabetes/roasted_chana.png',
          price: 40.0,
          type: FoodType.snacks,
          ingredients: [
            'Roasted chana - 50g',
            'Low fat curd - 100ml',
            'Cumin powder, salt, coriander',
          ],
          preparationSteps: [
            'Mix curd with water, add cumin and salt to make buttermilk.',
            'Serve with roasted chana.',
          ],
          nutrition: const NutritionInfo(protein: 6, carbs: 10, fat: 2, calories: 80),
        ),
      ],
    ),
  ],
);

final DiseaseModel hypertensionDisease = DiseaseModel(
  id: 'disease_hypertension',
  name: 'Hypertension',
  shortDescription:
  'High blood pressure — diet should be low in sodium and rich in potassium and magnesium.',
  longDescription:
  'Aim to reduce sodium intake and include potassium-rich foods like bananas, beetroots, leafy greens; prefer whole grains and lean proteins.',
  restrictedFoods: ['Excess salt', 'Processed foods', 'Pickles', 'High-sodium ready meals'],
  categories: [
    FoodCategoryModel(
      type: FoodType.tiffin,
      title: 'Tiffin',
      items: [
        FoodItemModel(
          id: 'hyper_tiffin_oats_banana',
          name: 'Oats Porridge with Banana',
          description: 'Warm oats porridge topped with sliced banana and seeds.',
          imagePath: 'assets/images/lunch/.png',
          price: 60.0,
          type: FoodType.tiffin,
          ingredients: [
            'Rolled oats - 1/2 cup',
            'Skim milk or water - 1 cup',
            'Banana - 1/2',
            'Flax seeds - 1 tsp',
          ],
          preparationSteps: [
            'Cook oats with milk or water.',
            'Top with banana slices and seeds.',
          ],
          nutrition: const NutritionInfo(protein: 6, carbs: 40, fat: 4, calories: 220),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.lunch,
      title: 'Lunch',
      items: [
        FoodItemModel(
          id: 'hyper_lunch_quinoa_salad',
          name: 'Quinoa & Spinach Salad with Grilled Fish',
          description: 'Protein-packed salad with quinoa, spinach and a piece of grilled fish.',
          imagePath: 'assets/images/hypertension/quinoa_fish.png',
          price: 180.0,
          type: FoodType.lunch,
          ingredients: [
            'Quinoa - 1 cup cooked',
            'Spinach - 1 cup',
            'Grilled fish fillet - 100g',
            'Olive oil, lemon',
          ],
          preparationSteps: [
            'Cook quinoa and grill fish with minimal salt.',
            'Toss spinach, quinoa and flaked fish with lemon and olive oil.',
          ],
          nutrition: const NutritionInfo(protein: 28, carbs: 40, fat: 8, calories: 360),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.dinner,
      title: 'Dinner',
      items: [
        FoodItemModel(
          id: 'hyper_dinner_mixed_veg_soup',
          name: 'Mixed Vegetable Soup + Grilled Paneer',
          description: 'Light soup without added salt served with grilled paneer cubes.',
          imagePath: 'assets/images/hypertension/veg_soup.png',
          price: 110.0,
          type: FoodType.dinner,
          ingredients: [
            'Mixed vegetables - 1 cup',
            'Low-sodium vegetable stock - 2 cups',
            'Paneer - 80g',
          ],
          preparationSteps: [
            'Boil vegetables in stock and blend to make soup.',
            'Grill paneer with pepper and herbs.',
            'Serve soup with paneer on side.',
          ],
          nutrition: const NutritionInfo(protein: 16, carbs: 20, fat: 10, calories: 240),
        ),
      ],
    ),
  ],
);

final DiseaseModel obesityDisease = DiseaseModel(
  id: 'disease_obesity',
  name: 'Obesity / Weight Management',
  shortDescription: 'Weight reduction focused diet — calorie deficit, high-protein, high-fiber.',
  longDescription:
  'Design meals that are satiating but calorie-controlled. Increase protein (to preserve lean mass), fiber (for satiety) and avoid liquid calories and refined carbs.',
  restrictedFoods: ['Sugary drinks', 'Fried snacks', 'Refined flour products'],
  categories: [
    FoodCategoryModel(
      type: FoodType.tiffin,
      title: 'Tiffin',
      items: [
        FoodItemModel(
          id: 'ob_tiffin_egg_sandwich',
          name: 'Egg & Veg Sandwich (Multi-grain)',
          description: 'Two slices of multi-grain bread with boiled egg and salad filling.',
          imagePath: 'assets/images/obesity/egg_sandwich.png',
          price: 75.0,
          type: FoodType.tiffin,
          ingredients: [
            'Multi-grain bread - 2 slices',
            'Boiled egg - 1',
            'Lettuce, cucumber, tomato',
          ],
          preparationSteps: [
            'Assemble sandwich with sliced egg and vegetables.',
            'Serve with green tea.',
          ],
          nutrition: const NutritionInfo(protein: 12, carbs: 30, fat: 6, calories: 240),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.lunch,
      title: 'Lunch',
      items: [
        FoodItemModel(
          id: 'ob_lunch_grilled_chicken_quinoa',
          name: 'Grilled Chicken & Quinoa Bowl',
          description: 'Lean grilled chicken breast served over quinoa with steamed veggies.',
          imagePath: 'assets/images/obesity/chicken_quinoa.png',
          price: 190.0,
          type: FoodType.lunch,
          ingredients: [
            'Quinoa - 1 cup cooked',
            'Chicken breast - 120g',
            'Broccoli, carrot - 1 cup',
          ],
          preparationSteps: [
            'Grill seasoned chicken breast; slice.',
            'Steam veggies and assemble bowl over quinoa.',
          ],
          nutrition: const NutritionInfo(protein: 36, carbs: 40, fat: 8, calories: 420),
        ),
      ],
    ),
    FoodCategoryModel(
      type: FoodType.snacks,
      title: 'Snacks',
      items: [
        FoodItemModel(
          id: 'ob_snack_roasted_seeds',
          name: 'Roasted Pumpkin & Sunflower Seeds',
          description: 'Small portion of roasted seeds as a crunchy low-cal snack.',
          imagePath: 'assets/images/obesity/seeds.png',
          price: 45.0,
          type: FoodType.snacks,
          ingredients: ['Pumpkin seeds - 20g', 'Sunflower seeds - 20g', 'Pinch of salt'],
          preparationSteps: ['Lightly roast seeds and cool before serving.'],
          nutrition: const NutritionInfo(protein: 8, carbs: 6, fat: 12, calories: 160),
        ),
      ],
    ),
  ],
);

final List<DiseaseModel> diseaseList = [diabetesDisease, hypertensionDisease, obesityDisease];

