import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Reference to the "orders" collection
  final CollectionReference orders = FirebaseFirestore.instance.collection("orders");

  /// ✅ Save an order to the Firestore database
  Future<void> saveOrderToDatabase({
    required List<Map<String, dynamic>> orderItems,
    required double total,
    required String address,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await orders.add({
      'userId': user.uid,
      'items': orderItems, // structured item list
      'total': total,
      'status': 'Processing',
      'address': address,
      'timestamp': Timestamp.now(),
    });
  }

  /// 👤 Get current user’s orders
  Stream<QuerySnapshot> getUserOrdersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return orders.where('userId', isEqualTo: user.uid).orderBy('timestamp', descending: true).snapshots();
  }

  /// 🚚 Update delivery status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await orders.doc(orderId).update({'status': newStatus, 'updatedAt': Timestamp.now()});
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
  /// For Admin or dashboard use
  Stream<QuerySnapshot> getAllOrdersStream() {
    return orders.orderBy('timestamp', descending: true).snapshots();
  }

  /// 🗑️ Delete an order (optional, e.g. canceled)
  Future<void> deleteOrder(String orderId) async {
    await orders.doc(orderId).delete();
  }

  /// 📦 Get a single order by its ID
  Future<DocumentSnapshot> getOrderById(String orderId) async {
    return await orders.doc(orderId).get();
  }
}
