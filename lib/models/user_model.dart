import 'package:cloud_firestore/cloud_firestore.dart';

/// ---------------- CART ITEM ----------------
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> addons;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.addons,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'addons': addons,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      addons: List<String>.from(map['addons'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

/// ---------------- PAYMENT MODEL ----------------
class PaymentModel {
  final String paymentId;
  final String method;
  final double amount;
  final String status;
  final Timestamp timestamp;

  PaymentModel({
    required this.paymentId,
    required this.method,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'method': method,
      'amount': amount,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: map['paymentId'] ?? '',
      method: map['method'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}

/// ---------------- ORDER MODEL ----------------
/// Added userId to associate order with a specific user
class OrderModel {
  final String orderId;
  final String userId; // ✅ NEW FIELD
  final List<CartItem> items;
  final double totalAmount;
  final String paymentId;
  final String paymentStatus;
  final String deliveryStatus;
  final String address;
  final String notes;
  final Timestamp orderDate;

  OrderModel({
    required this.orderId,
    required this.userId, // ✅ REQUIRED
    required this.items,
    required this.totalAmount,
    required this.paymentId,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.address,
    required this.notes,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId, // ✅ Added
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'address': address,
      'notes': notes,
      'orderDate': orderDate,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '', // ✅ Added
      items: map['items'] != null
          ? List<CartItem>.from(
              (map['items'] as List).map((item) => CartItem.fromMap(item)),
            )
          : [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentId: map['paymentId'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      deliveryStatus: map['deliveryStatus'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      orderDate: map['orderDate'] ?? Timestamp.now(),
    );
  }
}

/// ---------------- PROFILE FEATURES MODEL ----------------

class ProfileFeatures {
  final int age;
  final String gender;
  final int heightCm;
  final int weightKg;
  final double bmi;
  final String activityLevel;
  final String dietaryPreference;
  final String goal;
  final Timestamp lastUpdated;

  // 🩺 New fields for advanced recommendations
  final List<String> healthConditions; // e.g. ["Diabetes", "Hypertension"]
  final List<String> allergies; // e.g. ["Lactose", "Gluten"]
  final String cuisinePreference; // e.g. "South Indian"
  final List<String> tastePreference; // e.g. ["Less Oil", "Spicy"]
  final Map<String, String>
  mealTimings; // e.g. {"breakfast": "08:00 AM", "lunch": "01:00 PM"}

  ProfileFeatures({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.activityLevel,
    required this.dietaryPreference,
    required this.goal,
    required this.lastUpdated,
    this.healthConditions = const [],
    this.allergies = const [],
    this.cuisinePreference = "",
    this.tastePreference = const [],
    this.mealTimings = const {},
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bmi': bmi,
      'activityLevel': activityLevel,
      'dietaryPreference': dietaryPreference,
      'goal': goal,
      'lastUpdated': lastUpdated,

      // 🩺 New fields
      'healthConditions': healthConditions,
      'allergies': allergies,
      'cuisinePreference': cuisinePreference,
      'tastePreference': tastePreference,
      'mealTimings': mealTimings,
    };
  }

  /// Construct from Firestore map
  factory ProfileFeatures.fromMap(Map<String, dynamic> map) {
    return ProfileFeatures(
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      heightCm: map['heightCm'] ?? 0,
      weightKg: map['weightKg'] ?? 0,
      bmi: (map['bmi'] ?? 0).toDouble(),
      activityLevel: map['activityLevel'] ?? '',
      dietaryPreference: map['dietaryPreference'] ?? '',
      goal: map['goal'] ?? '',
      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),

      // 🩺 New fields (safe null handling)
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      cuisinePreference: map['cuisinePreference'] ?? '',
      tastePreference: List<String>.from(map['tastePreference'] ?? []),
      mealTimings: Map<String, String>.from(map['mealTimings'] ?? {}),
    );
  }
}

/// ---------------- USER MODEL ----------------
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String profileImageUrl;
  final String role;
  final bool isEmailVerified;
  final List<CartItem> cart;
  final List<OrderModel> orders;
  final List<PaymentModel> paymentMethods;
  final Map<String, dynamic> preferences;
  final ProfileFeatures? profileFeatures;
  final Timestamp createdAt;
  final Timestamp lastLogin;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.profileImageUrl,
    required this.role,
    required this.isEmailVerified,
    required this.cart,
    required this.orders,
    required this.paymentMethods,
    required this.preferences,
    required this.createdAt,
    required this.lastLogin,
    required this.updatedAt,
    this.profileFeatures,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'cart': cart.map((item) => item.toMap()).toList(),
      'orders': orders.map((order) => order.toMap()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toMap()).toList(),
      'preferences': preferences,
      'profileFeatures': profileFeatures?.toMap(),
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      role: map['role'] ?? 'user',
      isEmailVerified: map['isEmailVerified'] ?? false,
      cart: map['cart'] != null
          ? List<CartItem>.from(
              (map['cart'] as List).map((item) => CartItem.fromMap(item)),
            )
          : [],
      orders: map['orders'] != null
          ? List<OrderModel>.from(
              (map['orders'] as List).map((o) => OrderModel.fromMap(o)),
            )
          : [],
      paymentMethods: map['paymentMethods'] != null
          ? List<PaymentModel>.from(
              (map['paymentMethods'] as List).map(
                (p) => PaymentModel.fromMap(p),
              ),
            )
          : [],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      profileFeatures: map['profileFeatures'] != null
          ? ProfileFeatures.fromMap(
              Map<String, dynamic>.from(map['profileFeatures']),
            )
          : null,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastLogin: map['lastLogin'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
