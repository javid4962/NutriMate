import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_mate/services/database/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: user == null
          ? const Center(
        child: Text(
          "Please log in to view your orders.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUserOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No active orders yet 🛍️",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final orderData = order.data() as Map<String, dynamic>;
              final List items = orderData['items'] ?? [];
              final status = orderData['status'] ?? 'Processing';
              final total = orderData['total'] ?? 0.0;
              final timestamp =
              (orderData['timestamp'] as Timestamp?)?.toDate();

              final color = status == 'Delivered'
                  ? Colors.green
                  : status == 'Out for Delivery'
                  ? Colors.orange
                  : Colors.grey;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: ExpansionTile(
                  tilePadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 10),
                  leading: Icon(
                    Icons.receipt_long_rounded,
                    color: color,
                    size: 30,
                  ),
                  title: Text(
                    "Order #${orderId.substring(0, 6)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Total: ₹${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (timestamp != null)
                        Text(
                          "Placed on: ${timestamp.toLocal().toString().substring(0, 16)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  children: [
                    const Divider(thickness: 0.6),

                    // 🧭 Delivery Progress Tracker
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _buildDeliveryTimeline(status),
                    ),

                    const Divider(thickness: 0.6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final addons = (item['addons'] as List?) ?? [];
                        return Container(
                          margin:
                          const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildImage(item['imageUrl']),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Unknown Item',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Qty: ${item['quantity']}",
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13),
                                    ),
                                    if (addons.isNotEmpty)
                                      Text(
                                        "Add-ons: ${addons.join(', ')}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${item['price'].toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🕒 Delivery Progress Timeline
  Widget _buildDeliveryTimeline(String status) {
    final steps = [
      {"title": "Order Placed", "icon": Icons.shopping_bag},
      {"title": "Preparing Food", "icon": Icons.restaurant_menu},
      {"title": "Out for Delivery", "icon": Icons.delivery_dining},
      {"title": "Delivered", "icon": Icons.check_circle},
    ];

    int currentStep = 0;
    if (status == "Preparing Food") currentStep = 1;
    else if (status == "Out for Delivery") currentStep = 2;
    else if (status == "Delivered") currentStep = 3;

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;

        final String stepTitle = steps[index]["title"] as String;
        final IconData stepIcon = steps[index]["icon"] as IconData;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  stepIcon,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 26,
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 35,
                    color: isCompleted ? Colors.green : Colors.grey.shade400,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                stepTitle,
                style: TextStyle(
                  fontWeight:
                  isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.green : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 🧩 Smart Image Builder — gracefully handles missing/invalid URLs
  Widget _buildImage(dynamic imageUrl) {
    try {
      final String url = imageUrl?.toString() ?? '';

      if (url.isEmpty) {
        return Image.asset(
          'lib/images/default/loading.gif',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }

      if (url.startsWith('http')) {
        return Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'lib/images/default/loading.gif',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      } else if (url.startsWith('assets/') || url.contains('lib/images')) {
        return Image.asset(
          url.replaceAll('file:///', ''),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'lib/images/default/loading.gif',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        return Image.asset(
          'lib/images/default/loading.gif',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return Image.asset(
        'lib/images/default/loading.gif',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }
}
