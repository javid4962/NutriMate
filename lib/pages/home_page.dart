import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_description_box.dart';
import 'package:nutri_mate/components/my_drawer.dart';
import 'package:nutri_mate/components/my_food_tile.dart';
import 'package:nutri_mate/components/my_sliver_app_bar.dart';
import 'package:nutri_mate/components/my_tab_bar.dart';
import 'package:nutri_mate/models/food.dart';
import 'package:nutri_mate/pages/food_page.dart';
import 'package:provider/provider.dart';

import '../components/my_current_location.dart';
import '../models/restaurant.dart';

// 👇 Import the new disease data and mapper
import '../models/disease_models_and_mock_data.dart';
import '../models/disease_food_mapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Added: selected disease
  DiseaseModel? selectedDisease;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: FoodCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // filtering the food items by category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  // return list of foods in this category
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

  // 🩺 Disease selection dropdown widget
  Widget buildDiseaseSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: DropdownButtonFormField<DiseaseModel>(
        decoration: const InputDecoration(
          labelText: 'Select Disease',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.medical_services_outlined),
        ),
        value: selectedDisease,
        items: diseaseList.map((disease) {
          return DropdownMenuItem(
            value: disease,
            child: Text(disease.name),
          );
        }).toList(),
        onChanged: (newDisease) {
          setState(() {
            selectedDisease = newDisease;
          });
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

          // ✅ Step 1: choose which menu to show
          final List<Food> currentMenu = selectedDisease != null
              ? selectedDisease!.asFoodList // from mapper
              : restaurant.menu; // default restaurant menu

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

                    // 👇 Add the Disease Selector here
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildDiseaseSelector(),
                    ),
                    const SizedBox(height: 10),

                    const MyDescriptionBox(),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: getFoodsInThisCategory(currentMenu),
            ),
          );
        },
      ),
    );
  }
}
