import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class UserService {
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // Create or update user document
  Future<void> createOrUpdateUser(UserModel user) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    await users.doc(user.uid).set({
      ...user.toMap(),
      'isEmailVerified': refreshedUser?.emailVerified ?? false,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // ✅ Update or create user profile features
  Future<void> updateUserProfileFeatures({
    required String uid,
    required int age,
    required String gender,
    required int heightCm,
    required int weightKg,
    required String activityLevel,
    required String dietaryPreference,
    String? goal, required Map<String, Object> extraData,
  }) async {
    double heightM = heightCm / 100;
    double bmi = heightM > 0 ? double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1)) : 0;

    await users.doc(uid).set({
      'profileFeatures': {
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bmi': bmi,
        'activityLevel': activityLevel,
        'dietaryPreference': dietaryPreference,
        'goal': goal ?? '',
        'lastUpdated': Timestamp.now(),
      },
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // ✅ Cart + Other methods remain unchanged
  Future<void> updateCart(String uid, List<CartItem> cartItems) async {
    final userRef = users.doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid,
        'cart': [],
        'createdAt': Timestamp.now(),
        'isEmailVerified': false,
      });
    }

    await userRef.set({
      'cart': cartItems.map((item) => item.toMap()).toList(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<UserModel?> streamUser(String uid) {
    return users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> addOrder(String uid, OrderModel order) async {
    await users.doc(uid).set({
      'orders': FieldValue.arrayUnion([order.toMap()]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> addPayment(String uid, PaymentModel payment) async {
    await users.doc(uid).set({
      'paymentMethods': FieldValue.arrayUnion([payment.toMap()]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
