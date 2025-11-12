import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/disease_models_and_mock_data.dart';

/// ML-based (Rule-based) Food Recommendation Service
/// Provides personalized food suggestions based on:
/// - Disease (Health condition)
/// - Meal type (Breakfast, Lunch, Dinner, Snacks)
/// - Diet preference (Vegan, Vegetarian, Non-Veg, Pescatarian)
/// - Cuisine preference
/// - Nutritional requirements
class MLRecommendationService {
  static final MLRecommendationService _instance =
      MLRecommendationService._internal();
  factory MLRecommendationService() => _instance;
  MLRecommendationService._internal();

  List<FoodRecommendation>? _allFoods;
  bool _isInitialized = false;

  /// Initialize the service by loading and parsing CSV data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('📦 Loading CSV data from assets...');
      final csvData = await rootBundle.loadString(
        'assets/data/disease_food_recommendations_v2.csv',
      );
      print('✅ CSV data loaded, raw length: ${csvData.length}');

      // Normalize line endings and remove BOM if present
      final normalized = csvData
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\uFEFF', '') // Remove UTF-8 BOM
          .trim();

      // Parse CSV safely
      final List<List<dynamic>> rows = const CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
        shouldParseNumbers: false,
      ).convert(normalized);

      print('🧮 Parsed ${rows.length} rows from CSV');

      _allFoods = [];

      if (rows.isEmpty || rows.length < 2) {
        print('⚠️ CSV appears empty or malformed — no data rows found.');
        _isInitialized = true;
        return;
      }

      // Skip header row
      final header = rows.first;
      print('🧾 CSV Header: $header');

      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];
          if (row.length >= 12) {
            final food = FoodRecommendation.fromCsvRow(row);
            _allFoods!.add(food);
          } else {
            print('⚠️ Skipping row $i — insufficient columns (${row.length})');
          }
        } catch (e) {
          print('❌ Error parsing row $i: $e');
        }
      }

      print(
        '🍽️ ML Recommendation Service initialized with ${_allFoods!.length} foods',
      );
      _isInitialized = true;
    } catch (e) {
      print('❌ Error initializing ML Recommendation Service: $e');
      _allFoods = [];
      _isInitialized = true;
    }
  }

  /// Get personalized food recommendations
  Future<List<FoodRecommendation>> getRecommendations({
    required String disease,
    FoodType? mealType,
    String? dietPreference,
    String? cuisinePreference,
    int maxResults = 20,
    Map<String, double>? nutritionTargets,
  }) async {
    if (!_isInitialized) await initialize();

    if (_allFoods == null || _allFoods!.isEmpty) {
      print('⚠️ No foods available for recommendation.');
      return [];
    }

    List<ScoredFood> scoredFoods = [];

    for (var food in _allFoods!) {
      double score = _calculateRecommendationScore(
        food: food,
        disease: disease,
        mealType: mealType,
        dietPreference: dietPreference,
        cuisinePreference: cuisinePreference,
        nutritionTargets: nutritionTargets,
      );

      if (score > 0) scoredFoods.add(ScoredFood(food: food, score: score));
    }

    // Sort and return top results
    scoredFoods.sort((a, b) => b.score.compareTo(a.score));
    return scoredFoods.take(maxResults).map((sf) => sf.food).toList();
  }

  /// Calculate recommendation score
  double _calculateRecommendationScore({
    required FoodRecommendation food,
    required String disease,
    FoodType? mealType,
    String? dietPreference,
    String? cuisinePreference,
    Map<String, double>? nutritionTargets,
  }) {
    double score = 0.0;

    // 1️⃣ Disease match
    if (food.disease.toLowerCase() == disease.toLowerCase()) {
      score += 40.0;
    } else {
      return 0.0; // Strict match required
    }

    // 2️⃣ Meal type match
    if (mealType != null && food.mealType == mealType) {
      score += 20.0;
    } else if (mealType != null) {
      score += 5.0;
    }

    // 3️⃣ Diet preference
    if (dietPreference != null) {
      if (food.dietType.toLowerCase() == dietPreference.toLowerCase()) {
        score += 15.0;
      } else if (_isDietCompatible(food.dietType, dietPreference)) {
        score += 7.5;
      }
    }

    // 4️⃣ Cuisine preference
    if (cuisinePreference != null &&
        food.cuisine.toLowerCase() == cuisinePreference.toLowerCase()) {
      score += 10.0;
    }

    // 5️⃣ Nutrition alignment
    score += _calculateNutritionScore(food, nutritionTargets);

    return score;
  }

  /// Check if diet types are compatible
  bool _isDietCompatible(String foodDiet, String userDiet) {
    foodDiet = foodDiet.toLowerCase();
    userDiet = userDiet.toLowerCase();

    if (userDiet == 'vegan') return foodDiet == 'vegan';
    if (userDiet == 'vegetarian')
      return foodDiet == 'vegan' || foodDiet == 'vegetarian';
    if (userDiet == 'pescatarian')
      return foodDiet == 'vegan' ||
          foodDiet == 'vegetarian' ||
          foodDiet == 'pescatarian';

    return true; // non-veg can eat anything
  }

  /// Calculate nutrition alignment score
  double _calculateNutritionScore(
    FoodRecommendation food,
    Map<String, double>? targets,
  ) {
    if (targets == null || targets.isEmpty) return 10.0;

    double score = 0.0;
    int count = 0;

    void addComponent(String key, double value, double weight) {
      if (!targets.containsKey(key)) return;
      count++;
      double diff = (value - targets[key]!).abs();
      double maxDiff = targets[key]! * 0.3;
      score += (1 - (diff / maxDiff).clamp(0.0, 1.0)) * weight;
    }

    addComponent('calories', food.calories, 5.0);
    addComponent('protein', food.protein, 5.0);
    addComponent('carbs', food.carbs, 2.5);
    addComponent('fats', food.fats, 2.5);

    return count > 0 ? score : 10.0;
  }

  /// List of all diseases available
  Future<List<String>> getAvailableDiseases() async {
    if (!_isInitialized) await initialize();
    return _allFoods!.map((f) => f.disease).toSet().toList()..sort();
  }

  /// List of available cuisines for a specific disease
  Future<List<String>> getAvailableCuisines(String disease) async {
    if (!_isInitialized) await initialize();

    return _allFoods!
        .where((f) => f.disease.toLowerCase() == disease.toLowerCase())
        .map((f) => f.cuisine)
        .toSet()
        .toList()
      ..sort();
  }

  /// List of diet types
  Future<List<String>> getAvailableDietTypes() async {
    if (!_isInitialized) await initialize();
    return _allFoods!.map((f) => f.dietType).toSet().toList()..sort();
  }

  /// Convert FoodRecommendation → FoodItemModel
  FoodItemModel toFoodItemModel(FoodRecommendation r) {
    return FoodItemModel(
      id: 'ml_${r.foodName.toLowerCase().replaceAll(' ', '_')}',
      name: r.foodName,
      description: r.healthNotes,
      imagePath: 'lib/images/default/not_found.png',
      price: _estimatePrice(r),
      type: r.mealType,
      ingredients: r.ingredients.split(',').map((e) => e.trim()).toList(),
      preparationSteps: r.preparationSteps
          .split('.')
          .where((s) => s.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList(),
      nutrition: NutritionInfo(
        protein: r.protein,
        carbs: r.carbs,
        fat: r.fats,
        calories: r.calories,
      ),
    );
  }

  /// Rough price estimator (for UI)
  double _estimatePrice(FoodRecommendation f) {
    double price = 50.0 + (f.protein / 10) * 10;
    if (f.dietType.toLowerCase().contains('non')) price += 30.0;
    if (f.dietType.toLowerCase().contains('pescatarian')) price += 40.0;
    if (f.cuisine.toLowerCase().contains('continental')) price += 20.0;
    return price.roundToDouble();
  }
}

/// FoodRecommendation model — from CSV
class FoodRecommendation {
  final String disease;
  final FoodType mealType;
  final String foodName;
  final String dietType;
  final String cuisine;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String ingredients;
  final String preparationSteps;
  final String healthNotes;

  FoodRecommendation({
    required this.disease,
    required this.mealType,
    required this.foodName,
    required this.dietType,
    required this.cuisine,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.preparationSteps,
    required this.healthNotes,
  });

  factory FoodRecommendation.fromCsvRow(List<dynamic> row) {
    return FoodRecommendation(
      disease: row[0].toString(),
      mealType: _parseMealType(row[1].toString()),
      foodName: row[2].toString(),
      dietType: row[3].toString(),
      cuisine: row[4].toString(),
      calories: _parseDouble(row[5]),
      protein: _parseDouble(row[6]),
      carbs: _parseDouble(row[7]),
      fats: _parseDouble(row[8]),
      ingredients: row[9].toString(),
      preparationSteps: row[10].toString(),
      healthNotes: row[11].toString(),
    );
  }

  static FoodType _parseMealType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return FoodType.tiffin;
      case 'lunch':
        return FoodType.lunch;
      case 'dinner':
        return FoodType.dinner;
      case 'snack':
      case 'snacks':
        return FoodType.snacks;
      default:
        return FoodType.lunch;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Helper class for scoring
class ScoredFood {
  final FoodRecommendation food;
  final double score;
  ScoredFood({required this.food, required this.score});
}
