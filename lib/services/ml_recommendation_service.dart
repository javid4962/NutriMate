import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class MLRecommendationService {
  // 🔹 Your live ngrok or API URL
  static const String _baseUrl = "https://nutrimate-main2.onrender.com";

  /// Fetch all diseases available from the backend
  Future<List<String>> getAvailableDiseases() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/available_diseases"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print("❌ Error fetching diseases: $e");
      return [];
    }
  }

  /// Fetch personalized food recommendations
  Future<List<Food>> getRecommendations({
    required String disease,
    String? mealType,
    String? dietPreference,
    String? cuisinePreference,
    int maxResults = 20,
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/recommend");
      final payload = {
        "disease": disease,
        "meal_type": mealType ?? "",
        "diet_type": dietPreference ?? "",
        "cuisine": cuisinePreference ?? "",
        "max_results": maxResults,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((item) => _parseFood(item)).toList();
      } else {
        print("❌ Failed to fetch recommendations: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching ML recommendations: $e");
      return [];
    }
  }

  /// Parse a Food object safely from backend JSON
  Food _parseFood(Map<String, dynamic> item) {
    return Food(
      name: item['food_name']?.toString() ?? "Unknown Food",
      description:
          item['health_notes']?.toString() ?? "No description available",
      imagePath: _resolveImagePath(item['image_url']),
      price: _estimatePrice(item),
      category: _mapMealType(item['meal_type']),
      availableAddons: [], // ML-based recommendations don’t include addons
      ingredients: _parseList(item['ingredients']),
      preparationSteps: _parseList(item['preparation_steps']),
      nutrition: {
        "calories": _parseDouble(item['calories']),
        "protein": _parseDouble(item['protein']),
        "carbs": _parseDouble(item['carbs']),
        "fats": _parseDouble(item['fats']),
      },
    );
  }

  /// Handle ingredients / steps flexibly (string or array)
  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      // Handles comma- or period-separated strings
      if (value.contains(',')) {
        return value.split(',').map((e) => e.trim()).toList();
      } else if (value.contains('.')) {
        return value
            .split('.')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [value];
    }
    return [];
  }

  /// Safely parse double values
  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  /// Fallback image handler
  String _resolveImagePath(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return 'lib/images/default/loading.gif';
  }

  /// Estimate price heuristically (optional enhancement)
  double _estimatePrice(Map<String, dynamic> item) {
    final protein = _parseDouble(item['protein']);
    final calories = _parseDouble(item['calories']);
    double price = 60 + (protein * 2) + (calories / 50);
    return double.parse(price.toStringAsFixed(2));
  }

  /// Map text meal type to FoodCategory enum
  FoodCategory _mapMealType(dynamic val) {
    // if (val == null) return FoodCategory.other;
    final str = val.toString().toLowerCase();

    if (str.contains("breakfast") || str.contains("tiffin")) {
      return FoodCategory.Tiffin;
    } else if (str.contains("lunch")) {
      return FoodCategory.Lunch;
    } else if (str.contains("dinner")) {
      return FoodCategory.Dinner;
    } else {
      return FoodCategory.Snacks;
    }

    // else {
    //   // return FoodCategory.other;
    // }
  }
}
