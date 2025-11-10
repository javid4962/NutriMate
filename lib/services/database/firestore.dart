import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Reference to the "orders" collection
  final CollectionReference orders = FirebaseFirestore.instance.collection("orders");

  /// ✅ Save an order to the Firestore database
  Future<void> saveOrderToDatabase(String receipt) async {
    await orders.add({
      'order': receipt,
      'total': _extractTotal(receipt),
      'status': 'Processing', // initial status
      'timestamp': Timestamp.now(),
    });
  }

  /// 🧾 Extracts total price from the receipt string
  double _extractTotal(String receipt) {
    // Example match: "Total: ₹150.00"
    final regex = RegExp(r'Total:\s*₹(\d+(\.\d+)?)');
    final match = regex.firstMatch(receipt);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
  }

  /// 🔄 Get a live stream of all orders (ordered by time)
  Stream<QuerySnapshot> getOrdersStream() {
    return orders.orderBy('timestamp', descending: true).snapshots();
  }

  /// 🚚 Update order status (for delivery progress)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await orders.doc(orderId).update({'status': newStatus});
  }

  /// 🗑️ Delete an order (optional, e.g. canceled)
  Future<void> deleteOrder(String orderId) async {
    await orders.doc(orderId).delete();
  }
}
