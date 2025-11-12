import 'package:flutter/material.dart';
import 'package:nutri_mate/models/food.dart';
import 'package:nutri_mate/pages/food_page.dart';
import '../services/ml_recommendation_service.dart';
import '../components/my_food_tile.dart';

class MLRecommendationDemoPage extends StatefulWidget {
  const MLRecommendationDemoPage({super.key});

  @override
  State<MLRecommendationDemoPage> createState() =>
      _MLRecommendationDemoPageState();
}

class _MLRecommendationDemoPageState extends State<MLRecommendationDemoPage> {
  final MLRecommendationService _mlService = MLRecommendationService();

  bool _isLoading = false;
  List<Food> _recommendations = [];

  String? _selectedDisease;
  String? _selectedMealType;
  String? _selectedDietType;
  String? _selectedCuisine;

  List<String> _diseases = [];
  final List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"];
  final List<String> _dietTypes = [
    "Vegan",
    "Vegetarian",
    "Non-Vegetarian",
    "Pescatarian",
  ];
  final List<String> _cuisines = [
    "Indian",
    "Continental",
    "Mediterranean",
    "Asian",
  ];

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    final diseases = await _mlService.getAvailableDiseases();
    setState(() => _diseases = diseases);
  }

  Future<void> _getRecommendations() async {
    if (_selectedDisease == null) return;
    setState(() => _isLoading = true);

    final foods = await _mlService.getRecommendations(
      disease: _selectedDisease!,
      mealType: _selectedMealType,
      dietPreference: _selectedDietType,
      cuisinePreference: _selectedCuisine,
    );

    setState(() {
      _recommendations = foods;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 ML Recommendation Demo"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDisease,
              decoration: const InputDecoration(
                labelText: "Select Disease",
                border: OutlineInputBorder(),
              ),
              items: _diseases
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDisease = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: "Meal Type",
                border: OutlineInputBorder(),
              ),
              items: _mealTypes
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMealType = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDietType,
              decoration: const InputDecoration(
                labelText: "Diet Preference",
                border: OutlineInputBorder(),
              ),
              items: _dietTypes
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDietType = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCuisine,
              decoration: const InputDecoration(
                labelText: "Cuisine Preference",
                border: OutlineInputBorder(),
              ),
              items: _cuisines
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCuisine = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getRecommendations,
              icon: const Icon(Icons.search),
              label: const Text("Get Recommendations"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                  ? const Center(child: Text("No recommendations yet"))
                  : ListView.builder(
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        final food = _recommendations[index];
                        return FoodTile(
                          food: food,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodPage(food: food),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
