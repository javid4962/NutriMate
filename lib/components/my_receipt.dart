import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyReceipt extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double total;
  final String address;

  const MyReceipt({
    super.key,
    required this.orderItems,
    required this.total,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
    DateFormat("dd-MM-yyyy hh:mm:ss a").format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Text(
              "Thank you for ordering",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: $formattedDate"),
                  const Divider(),
                  ...orderItems.map((item) => Text(
                    "${item['quantity']} × ${item['name']} (₹${item['price']})",
                    style: const TextStyle(fontSize: 14),
                  )),
                  const Divider(),
                  Text("Total: ₹${total.toStringAsFixed(2)}"),
                  Text("Address: $address"),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text("Estimated Delivery Time: 00:00"),
          ],
        ),
      ),
    );
  }
}
