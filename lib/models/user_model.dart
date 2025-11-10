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
class OrderModel {
  final String orderId;
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
      items: map['items'] != null
          ? List<CartItem>.from(
          (map['items'] as List).map((item) => CartItem.fromMap(item)))
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
          (map['cart'] as List).map((item) => CartItem.fromMap(item)))
          : [],
      orders: map['orders'] != null
          ? List<OrderModel>.from(
          (map['orders'] as List).map((o) => OrderModel.fromMap(o)))
          : [],
      paymentMethods: map['paymentMethods'] != null
          ? List<PaymentModel>.from((map['paymentMethods'] as List)
          .map((p) => PaymentModel.fromMap(p)))
          : [],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastLogin: map['lastLogin'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
