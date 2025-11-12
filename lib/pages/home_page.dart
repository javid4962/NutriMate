import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_description_box.dart';
import 'package:nutri_mate/components/my_drawer.dart';
import 'package:nutri_mate/components/my_food_tile.dart';
import 'package:nutri_mate/components/my_sliver_app_bar.dart';
import 'package:nutri_mate/components/my_tab_bar.dart';
import 'package:nutri_mate/models/disease_models_and_mock_data.dart';
import 'package:nutri_mate/models/food.dart';
import 'package:nutri_mate/pages/food_page.dart';
import 'package:provider/provider.dart';

import '../components/my_current_location.dart';
import '../models/restaurant.dart';

// ML Recommendation Service
import '../services/ml_recommendation_service.dart';
import 'ml_recommendation_demo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MLRecommendationService _mlService = MLRecommendationService();

  bool _isLoadingRecommendations = false;
  bool _isLoadingDiseases = true;
  List<String> _diseases = [];
  String? selectedDiseaseName;

  List<Food> _recommendedFoods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: FoodCategory.values.length,
      vsync: this,
    );
    _initializeMLService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 🔹 Initialize ML service and load diseases
  Future<void> _initializeMLService() async {
    try {
      await _mlService.initialize();
      final diseases = await _mlService.getAvailableDiseases();
      setState(() {
        _diseases = diseases;
        _isLoadingDiseases = false;
      });
    } catch (e) {
      setState(() => _isLoadingDiseases = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading diseases: $e')));
    }
  }

  /// 🔍 Fetch ML-based recommendations
  Future<void> _loadRecommendations(String diseaseName) async {
    setState(() => _isLoadingRecommendations = true);

    try {
      final recommendations = await _mlService.getRecommendations(
        disease: diseaseName,
        maxResults: 20,
      );

      final List<Food> foods = recommendations.map((r) {
        final model = _mlService.toFoodItemModel(r);
        return Food(
          name: model.name,
          description: model.description,
          imagePath: _safeImagePath(model.imagePath),
          price: model.price,
          category: _mapMealTypeToCategory(model.type),
          availableAddons: [], // required field for Food
          ingredients: model.ingredients,
          preparationSteps: model.preparationSteps,
          nutrition: model.nutrition,
        );
      }).toList();

      setState(() {
        _recommendedFoods = foods;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecommendations = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ML recommendations: $e')),
      );
    }
  }

  /// 🔹 Fallback image path
  String _safeImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return "lib/images/default/loading.gif";
    }
    return path;
  }

  /// 🔹 Convert ML FoodType → FoodCategory
  FoodCategory _mapMealTypeToCategory(FoodType type) {
    switch (type) {
      case FoodType.tiffin:
        return FoodCategory.Tiffin;
      case FoodType.lunch:
        return FoodCategory.Lunch;
      case FoodType.dinner:
        return FoodCategory.Dinner;
      case FoodType.snacks:
        return FoodCategory.Snacks;
    }
  }

  /// 🔹 Filter menu items by category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  /// 🔹 Get list of foods under each tab category
  List<Widget> getFoodsInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);
      return ListView.builder(
        itemCount: categoryMenu.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final food = categoryMenu[index];
          return FoodTile(
            food: food,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodPage(food: food)),
              );
            },
          );
        },
      );
    }).toList();
  }

  /// 🧠 Disease Selector — ML-driven dropdown
  Widget buildDiseaseSelector() {
    if (_isLoadingDiseases) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: DropdownButtonFormField<String>(
        value: selectedDiseaseName,
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
            selectedDiseaseName = value;
            _recommendedFoods.clear();
          });
          if (value != null) _loadRecommendations(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          final cartItemCount = restaurant.cart.length;

          final List<Food> currentMenu = _isLoadingRecommendations
              ? []
              : selectedDiseaseName != null && _recommendedFoods.isNotEmpty
              ? _recommendedFoods
              : restaurant.menu;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              MySliverAppBar(
                title: MyTabBar(tabController: _tabController),
                cartItemCount: cartItemCount,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    MyCurrentLocation(),

                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildDiseaseSelector(),
                    ),
                    const SizedBox(height: 10),
                    const MyDescriptionBox(),

                    // const SizedBox(height: 10),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               const MLRecommendationDemoPage(),
                    //         ),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.smart_toy),
                    //     label: const Text('🧠 Test ML Recommendations'),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Theme.of(
                    //         context,
                    //       ).colorScheme.primary,
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
            body: _isLoadingRecommendations
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: getFoodsInThisCategory(currentMenu),
                  ),
          );
        },
      ),
    );
  }
}
