import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_button.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../models/restaurant.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  Map<Addons, bool> selectedAddons = {};

  FoodPage({super.key, required this.food}) {
    for (Addons addons in food.availableAddons) {
      selectedAddons[addons] = false;
    }
  }

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  void addToCart(Food food, Map<Addons, bool> selectedAddons) {
    Navigator.pop(context);
    List<Addons> selected = [];

    for (Addons addons in widget.food.availableAddons) {
      if (selectedAddons[addons] == true) selected.add(addons);
    }

    context.read<Restaurant>().addToCart(food, selected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${food.name} added to cart!"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 🖼️ Sliver App Bar for Food Image
              SliverAppBar(
                // automaticallyImplyLeading: false,

                expandedHeight: 280,
                pinned: true,
                backgroundColor: colors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                  title: Text(
                    widget.food.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.secondary,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  background: Hero(
                    tag: widget.food.name,
                    child: Image.asset(
                      widget.food.imagePath.isEmpty
                          ? 'lib/images/default/loading.gif'
                          : widget.food.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) =>
                          Image.asset('lib/images/default/loading.gif', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              // 🧾 Food Details Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💰 Price
                      Text(
                        "₹${widget.food.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 🧾 Description
                      Text(
                        widget.food.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.inversePrimary.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),
                      Divider(color: colors.secondary, thickness: 1),

                      // 🌿 Ingredients
                      if (widget.food.ingredients != null &&
                          widget.food.ingredients!.isNotEmpty)
                        _buildCardSection(
                          title: "Ingredients",
                          icon: Icons.eco_rounded,
                          items: widget.food.ingredients!,
                          colors: colors,
                        ),

                      // 🍳 Preparation Steps
                      if (widget.food.preparationSteps != null &&
                          widget.food.preparationSteps!.isNotEmpty)
                        _buildCardSection(
                          title: "Preparation Steps",
                          icon: Icons.restaurant_rounded,
                          items: widget.food.preparationSteps!,
                          colors: colors,
                          numbered: true,
                        ),

                      // 🧬 Nutrition Info
                      if (widget.food.nutrition != null)
                        _buildNutritionSection(widget.food.nutrition, colors),

                      const SizedBox(height: 25),

                      // ➕ Add-ons
                      Text(
                        "Add-ons",
                        style: TextStyle(
                          color: colors.inversePrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: colors.tertiary,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.food.availableAddons.length,
                          itemBuilder: (context, index) {
                            Addons addons = widget.food.availableAddons[index];
                            return CheckboxListTile(
                              activeColor: colors.primary,
                              title: Text(addons.name,
                                  style: TextStyle(
                                      color: colors.inversePrimary, fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                "₹${addons.price.toStringAsFixed(2)}",
                                style: TextStyle(color: colors.primary),
                              ),
                              value: widget.selectedAddons[addons],
                              onChanged: (bool? value) {
                                setState(() => widget.selectedAddons[addons] = value!);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🛒 Add to Cart Button
                      MyButton(
                        onTap: () => addToCart(widget.food, widget.selectedAddons),
                        text: "Add to Cart",
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 🔙 Back Button Floating
          // Positioned(
          //   top: 40,
          //   left: 16,
          //   child: CircleAvatar(
          //     backgroundColor: colors.tertiary.withOpacity(0.8),
          //     child: IconButton(
          //       icon: Icon(Icons.arrow_back_rounded, color: colors.primary),
          //       onPressed: () => Navigator.pop(context),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // 🌿 Card Section Builder (Ingredients / Steps)
  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required ColorScheme colors,
    bool numbered = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        elevation: 3,
        color: colors.tertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: colors.outline, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final text = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      numbered
                          ? CircleAvatar(
                        radius: 12,
                        backgroundColor: colors.primaryContainer,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                          : Icon(Icons.check_circle_outline,
                          color: colors.primaryContainer, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: colors.inversePrimary.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 🧬 Nutrition Section
  Widget _buildNutritionSection(dynamic nutrition, ColorScheme colors) {
    double protein = 0, carbs = 0, fat = 0, calories = 0;

    if (nutrition is Map) {
      protein = (nutrition["protein"] ?? 0).toDouble();
      carbs = (nutrition["carbs"] ?? 0).toDouble();
      fat = (nutrition["fat"] ?? 0).toDouble();
      calories = (nutrition["calories"] ?? 0).toDouble();
    } else {
      protein = (nutrition.protein ?? 0).toDouble();
      carbs = (nutrition.carbs ?? 0).toDouble();
      fat = (nutrition.fat ?? 0).toDouble();
      calories = (nutrition.calories ?? 0).toDouble();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Card(
        color: colors.tertiary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: colors.outline),
                  const SizedBox(width: 8),
                  Text(
                    "Nutritional Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _nutritionRow("Protein", "$protein g", colors),
              _nutritionRow("Carbohydrates", "$carbs g", colors),
              _nutritionRow("Fat", "$fat g", colors),
              _nutritionRow("Calories", "$calories kcal", colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.inversePrimary)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.primary)),
        ],
      ),
    );
  }
}
