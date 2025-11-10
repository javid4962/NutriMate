import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_button.dart';
import 'package:nutri_mate/components/my_cart_tile.dart';
import 'package:nutri_mate/pages/payment_page.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        final userCart = restaurant.cart;

        // ✅ Safe print only if not empty
        if (userCart.isNotEmpty) {
          print(userCart[0].food.name);
        } else {
          print("Cart is empty");
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart Page'),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                onPressed: () {
                  if (userCart.isEmpty) return; // ✅ avoid unnecessary dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Are you sure you want to clear your cart?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            restaurant.clearCart();
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: userCart.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "🛒 Your cart is empty",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text("Go to Home",style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary),),
                      )
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: userCart.length,
                  itemBuilder: (context, index) {
                    final cartItem = userCart[index];
                    return MyCartTile(cartItem: cartItem);
                  },
                ),
              ),

              // ✅ Hide checkout button if empty
              if (userCart.isNotEmpty) ...[
                MyButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentPage()),
                    );
                  },
                  text: "Go to Checkout (₹${restaurant.getTotalPrice().toStringAsFixed(2)})",
                ),
                const SizedBox(height: 25),
              ],
            ],
          ),
        );
      },
    );
  }
}
