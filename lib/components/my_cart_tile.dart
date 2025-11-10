import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_quantity_selector.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/restaurant.dart';

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;
  const MyCartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondary,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade300,
                    child: Image.asset(
                      cartItem.food.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('lib/images/default/loading.gif', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 🧾 Food Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name (wraps properly)
                      Text(
                        cartItem.food.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Price
                      Text(
                        "₹ ${cartItem.food.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),


                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                // Quantity Selector
                QuantitySelector(
                  quantity: cartItem.quantity,
                  food: cartItem.food,
                  onIncrement: () {
                    restaurant.addToCart(cartItem.food, cartItem.selectedAddons);
                  },
                  onDecrement: () {
                    restaurant.removeCartItem(cartItem);
                  },
                ),
              ],
            ),

            // 🧩 Addons list
            if (cartItem.selectedAddons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cartItem.selectedAddons.map((addon) {
                  return Chip(
                    label: Text(
                      '${addon.name} (₹ ${addon.price})',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: StadiumBorder(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
