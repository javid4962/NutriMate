import 'package:flutter/material.dart';
import 'package:nutri_mate/services/database/firestore.dart';
import 'package:provider/provider.dart';
import '../components/my_receipt.dart';
import '../models/restaurant.dart';
import 'order_page.dart'; // ✅ Add this import

class DeliveryProgressPage extends StatefulWidget {
  const DeliveryProgressPage({super.key});

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  final FirestoreService db = FirestoreService();
  List<Map<String, dynamic>>? _orderSnapshot; // ✅ Stores static order data
  double _total = 0;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _saveOrderAndClearCart();
  }

  Future<void> _saveOrderAndClearCart() async {
    final restaurant = context.read<Restaurant>();

    // ✅ Make a static snapshot of the order before clearing the cart
    final orderItems = restaurant.cart.map((cartItem) {
      return {
        'name': cartItem.food.name,
        'quantity': cartItem.quantity,
        'price': cartItem.food.price,
        'addons': cartItem.selectedAddons.map((a) => a.name).toList(),
        'imageUrl': cartItem.food.imagePath,
      };
    }).toList();

    setState(() {
      _orderSnapshot = orderItems;
      _total = restaurant.getTotalPrice();
      _address = restaurant.deliveryAddress;
    });

    // ✅ Save structured order to Firestore
    await db.saveOrderToDatabase(
      orderItems: orderItems,
      total: _total,
      address: _address,
    );

    // 🗑️ Clear cart after saving, but only after UI has static data
    await Future.delayed(const Duration(seconds: 1));
    await restaurant.clearCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your order has been placed successfully 🎉"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPage()),
        );
        return false; // prevent default back
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Delivery"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
        body: Column(
          children: [
            if (_orderSnapshot != null)
              MyReceipt(
                orderItems: _orderSnapshot!,
                total: _total,
                address: _address,
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Javid",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Text(
                "Delivery Boy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
