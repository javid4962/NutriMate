import 'package:flutter/material.dart';
import '../services/ml_recommendation_service.dart';
import '../models/disease_models_and_mock_data.dart' as models;

class MLRecommendationDemoPage extends StatefulWidget {
  const MLRecommendationDemoPage({super.key});

  @override
  State<MLRecommendationDemoPage> createState() =>
      _MLRecommendationDemoPageState();
}

class _MLRecommendationDemoPageState extends State<MLRecommendationDemoPage> {
  final MLRecommendationService _mlService = MLRecommendationService();
  List<String> _diseases = [];
  List<String> _cuisines = [];
  List<String> _dietTypes = [];
  List<FoodRecommendation> _recommendations = [];

  String? _selectedDisease;
  models.FoodType? _selectedMealType;
  String? _selectedDiet;
  String? _selectedCuisine;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);

    try {
      await _mlService.initialize();
      _diseases = await _mlService.getAvailableDiseases();
      _dietTypes = await _mlService.getAvailableDietTypes();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing ML service: $e')),
      );
    }
  }

  Future<void> _loadRecommendations() async {
    if (_selectedDisease == null) return;

    setState(() => _isLoading = true);

    try {
      _recommendations = await _mlService.getRecommendations(
        disease: _selectedDisease!,
        mealType: _selectedMealType,
        dietPreference: _selectedDiet,
        cuisinePreference: _selectedCuisine,
        maxResults: 10,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting recommendations: $e')),
      );
    }
  }

  Future<void> _loadCuisines() async {
    if (_selectedDisease == null) return;

    try {
      _cuisines = await _mlService.getAvailableCuisines(_selectedDisease!);
      setState(() {});
    } catch (e) {
      print('Error loading cuisines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Food Recommendations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isInitialized
          ? _buildContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 ML-Powered Food Recommendations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get personalized food recommendations based on your health condition and preferences.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Filters Section
          _buildFilters(),

          const SizedBox(height: 24),

          // Get Recommendations Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedDisease != null ? _loadRecommendations : null,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Get Recommendations'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Results Section
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_recommendations.isNotEmpty)
            _buildRecommendations()
          else if (_selectedDisease != null)
            const Center(
              child: Text(
                'No recommendations found. Try adjusting your filters.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            const Center(
              child: Text(
                'Select a disease to get personalized recommendations.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎛️ Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Disease Selection
            DropdownButtonFormField<String>(
              value: _selectedDisease,
              decoration: const InputDecoration(
                labelText: 'Health Condition',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              items: _diseases.map((disease) {
                return DropdownMenuItem(value: disease, child: Text(disease));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDisease = value;
                  _selectedCuisine = null;
                  _recommendations.clear();
                });
                _loadCuisines();
              },
            ),

            const SizedBox(height: 16),

            // Meal Type Selection
            DropdownButtonFormField<models.FoodType>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Meal Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: models.FoodType.values.map((mealType) {
                return DropdownMenuItem(
                  value: mealType,
                  child: Text(_mealTypeToString(mealType)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMealType = value;
                  _recommendations.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            // Diet Type Selection
            DropdownButtonFormField<String>(
              value: _selectedDiet,
              decoration: const InputDecoration(
                labelText: 'Diet Preference',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco),
              ),
              items: _dietTypes.map((diet) {
                return DropdownMenuItem(value: diet, child: Text(diet));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiet = value;
                  _recommendations.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            // Cuisine Selection
            DropdownButtonFormField<String>(
              value: _selectedCuisine,
              decoration: const InputDecoration(
                labelText: 'Cuisine Preference',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _cuisines.map((cuisine) {
                return DropdownMenuItem(value: cuisine, child: Text(cuisine));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCuisine = value;
                  _recommendations.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🍽️ Top ${_recommendations.length} Recommendations',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = _recommendations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.foodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recommendation.dietType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation.healthNotes,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildNutrientChip(
                          '🍎 ${recommendation.calories.toInt()} cal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          '💪 ${recommendation.protein.toInt()}g protein',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          '🌾 ${recommendation.carbs.toInt()}g carbs',
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          '🥑 ${recommendation.fats.toInt()}g fat',
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.restaurant, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _mealTypeToString(recommendation.mealType),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.flag, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.cuisine,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _mealTypeToString(models.FoodType mealType) {
    switch (mealType) {
      case models.FoodType.tiffin:
        return 'Breakfast';
      case models.FoodType.lunch:
        return 'Lunch';
      case models.FoodType.dinner:
        return 'Dinner';
      case models.FoodType.snacks:
        return 'Snacks';
    }
  }
}
