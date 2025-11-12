import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_drawer.dart';
import 'package:nutri_mate/components/my_food_tile.dart';
import 'package:nutri_mate/components/my_sliver_app_bar.dart';
import 'package:nutri_mate/components/my_tab_bar.dart';
import 'package:nutri_mate/models/food.dart';
import 'package:nutri_mate/pages/food_page.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../services/ml_recommendation_service.dart';

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
  String? _selectedDiseaseName;
  List<Food> _recommendedFoods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: FoodCategory.values.length,
      vsync: this,
    );
    _loadDiseases();
    _loadRecommendations(null); // 👈 Load all foods on start
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 🔹 Load list of diseases for dropdown
  Future<void> _loadDiseases() async {
    try {
      final diseases = await _mlService.getAvailableDiseases();
      setState(() {
        _diseases = ["All Foods", ...diseases]; // 👈 prepend “All Foods”
        _isLoadingDiseases = false;
      });
    } catch (e) {
      setState(() => _isLoadingDiseases = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading diseases: $e')));
    }
  }

  /// 🔍 Fetch ML-based recommendations (including “All Foods”)
  Future<void> _loadRecommendations(String? diseaseName) async {
    setState(() => _isLoadingRecommendations = true);

    try {
      final recommendations = await _mlService.getRecommendations(
        disease: (diseaseName == null || diseaseName == "All Foods")
            ? "" // 👈 empty disease to show all foods
            : diseaseName,
        maxResults: 50,
      );

      setState(() {
        _recommendedFoods = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecommendations = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recommendations: $e')),
      );
    }
  }

  /// 🧠 Dropdown for disease selection
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
        value: _selectedDiseaseName,
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
            _selectedDiseaseName = value;
            _recommendedFoods.clear();
          });
          _loadRecommendations(value); // 👈 call for new recommendations
        },
      ),
    );
  }

  /// 🔹 Filter menu by category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  /// 🔹 Build each tab view for categories
  List<Widget> getFoodsInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      final categoryMenu = _filterMenuByCategory(category, fullMenu);
      if (categoryMenu.isEmpty) {
        return const Center(child: Text("No items found"));
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          final cartItemCount = restaurant.cart.length;

          final List<Food> currentMenu = _isLoadingRecommendations
              ? []
              : _recommendedFoods.isNotEmpty
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildDiseaseSelector(),
                    ),
                    const SizedBox(height: 10),
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
