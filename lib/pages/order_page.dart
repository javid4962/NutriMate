import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_mate/services/database/firestore.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No active orders yet 🛍️",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final orderData = order.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    "Order #${orderId.substring(0, 6)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Items: ${orderData['order'] ?? 'Unknown'}"),
                      const SizedBox(height: 5),
                      Text("Total: ₹${orderData['total'] ?? '0.00'}"),
                      const SizedBox(height: 5),
                      Text(
                        "Status: ${orderData['status'] ?? 'Processing'}",
                        style: TextStyle(
                          color: orderData['status'] == 'Delivered'
                              ? Colors.green
                              : orderData['status'] == 'Out for Delivery'
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Date: ${orderData['timestamp'] != null ? (orderData['timestamp'] as Timestamp).toDate().toString().substring(0, 16) : 'N/A'}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delivery_dining),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingPage(
                            orderId: orderId,
                            orderData: orderData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 🚚 Track single order visually
class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final status = orderData['status'] ?? 'Processing';

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${orderId.substring(0, 6)}"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delivery Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            _buildStatusStep("Order Placed", true),
            _buildStatusStep("Preparing Food", status != "Processing"),
            _buildStatusStep("Out for Delivery", status == "Out for Delivery" || status == "Delivered"),
            _buildStatusStep("Delivered", status == "Delivered"),
            const SizedBox(height: 40),
            const Divider(),
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(orderData['order'] ?? 'No items'),
            const SizedBox(height: 5),
            Text("Total: ₹${orderData['total'] ?? '0.00'}"),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text("Back to Orders"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(String title, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, color: completed ? Colors.black : Colors.grey)),
      ],
    );
  }
}
