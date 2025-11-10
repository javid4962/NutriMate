import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class UserService {
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // Create or update user document
  Future<void> createOrUpdateUser(UserModel user) async {
    // 🔁 Reload user to ensure latest verification status
    final firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    await users.doc(user.uid).set({
      ...user.toMap(),
      'isEmailVerified': refreshedUser?.emailVerified ?? false, // ✅ always fresh
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }


  // ✅ FIXED: create if not found
  Future<void> updateCart(String uid, List<CartItem> cartItems) async {
    final userRef = users.doc(uid);

    // If doc doesn't exist, create it first
    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid,
        'cart': [],
        'createdAt': Timestamp.now(),
        'isEmailVerified': false,
      });
    }

    // Then safely update
    await userRef.set({
      'cart': cartItems.map((item) => item.toMap()).toList(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Get user
  Future<UserModel?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Real-time listener
  Stream<UserModel?> streamUser(String uid) {
    return users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Add new order
  Future<void> addOrder(String uid, OrderModel order) async {
    await users.doc(uid).set({
      'orders': FieldValue.arrayUnion([order.toMap()]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Add payment record
  Future<void> addPayment(String uid, PaymentModel payment) async {
    await users.doc(uid).set({
      'paymentMethods': FieldValue.arrayUnion([payment.toMap()]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
