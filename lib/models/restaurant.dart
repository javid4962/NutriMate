import 'dart:async'; // ✅ Needed for StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../models/food.dart';
import '../models/user_model.dart' as user_data;
import '../services/user/user_service.dart'; // ✅ Alias to prevent name clash


class Restaurant extends ChangeNotifier {
  // ---------------------- MENU ----------------------
  final List<Food> _menu = [
    // ⚡ Your existing Food items go here (unchanged)
  ];

  // ---------------------- FIREBASE ----------------------
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------- STATE ----------------------
  final List<CartItem> _cart = [];
  String _deliveryAddress = 'Hyderabad';
  StreamSubscription<user_data.UserModel?>? _cartListener;

  // ---------------------- GETTERS ----------------------
  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;

  // ---------------------- REAL-TIME CART SYNC ----------------------

  /// Start Firestore → App cart sync
  Future<void> initializeCartSync() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Cancel any previous listeners (safety)
    await _cartListener?.cancel();

    // 🔁 Start listening to user's Firestore document
    _cartListener = _userService.streamUser(user.uid).listen((userModel) {
      if (userModel == null) return;
      _syncCartFromFirestore(userModel.cart);
    });
  }

  /// Stop listening when user logs out
  Future<void> stopCartSync() async {
    await _cartListener?.cancel();
    _cartListener = null;
  }

  /// 🔄 Apply Firestore cart changes to local cart
  void _syncCartFromFirestore(List<user_data.CartItem> remoteCart) {
    // Convert remote CartItem (from Firestore) → local CartItem (app model)
    final converted = remoteCart.map((r) {
      // You can map these fields properly once your CartItem model aligns
      final food = _menu.firstWhereOrNull((f) => f.name == r.name);
      if (food == null) return null;
      return CartItem(food: food, selectedAddons: [], quantity: r.quantity);
    }).whereType<CartItem>().toList();

    final isDifferent = !_areCartsEqual(converted, _cart);
    if (isDifferent) {
      _cart
        ..clear()
        ..addAll(converted);
      notifyListeners();
    }
  }

  /// 🧮 Compare two cart lists deeply
  bool _areCartsEqual(List<CartItem> a, List<CartItem> b) {
    const deepEq = DeepCollectionEquality();
    return deepEq.equals(
      a.map((e) => e.food.name).toList(),
      b.map((e) => e.food.name).toList(),
    );
  }

  // ---------------------- CART LOGIC ----------------------

  /// Add an item to cart & Firestore
  Future<void> addToCart(Food food, List<Addons> selectedAddons) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Find if similar item exists
    CartItem? existing = _cart.firstWhereOrNull((item) {
      bool sameFood = item.food.name == food.name;
      bool sameAddons =
      const ListEquality().equals(item.selectedAddons, selectedAddons);
      return sameFood && sameAddons;
    });

    if (existing != null) {
      existing.quantity++;
    } else {
      _cart.add(CartItem(food: food, selectedAddons: selectedAddons, quantity: 1));
    }

    notifyListeners();

    // 🔥 Sync to Firestore
    await _userService.updateCart(
      user.uid,
      _convertCartToFirestoreFormat(_cart),
    );
  }

  /// Remove item from cart
  Future<void> removeCartItem(CartItem cartItem) async {
    final user = _auth.currentUser;
    if (user == null) return;

    int index = _cart.indexOf(cartItem);
    if (index != -1) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();

      // 🔥 Sync to Firestore
      await _userService.updateCart(
        user.uid,
        _convertCartToFirestoreFormat(_cart),
      );
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _cart.clear();
    notifyListeners();
    await _userService.updateCart(user.uid, []);
  }

  /// Update delivery address
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  // ---------------------- HELPER METHODS ----------------------

  double getTotalPrice() {
    double total = 0;
    for (CartItem item in _cart) {
      double itemTotal = item.food.price;
      for (Addons addon in item.selectedAddons) {
        itemTotal += addon.price;
      }
      total += itemTotal * item.quantity;
    }
    return total;
  }

  int getTotalItemCount() {
    return _cart.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  String displayCartReceipt() {
    final receipt = StringBuffer();
    final formattedDate =
    DateFormat("dd-MM-yyyy hh:mm:ss a").format(DateTime.now());
    receipt.writeln("Date: $formattedDate\n");
    receipt.writeln("----------------------------------------------------");

    for (final cartItem in _cart) {
      receipt.writeln(
          "${cartItem.quantity} × ${cartItem.food.name} (${_formatPrice(cartItem.food.price)})");
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt.writeln("\tAdd-ons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      receipt.writeln();
    }

    receipt.writeln("----------------------------------------------------");
    receipt.writeln("Total: ${_formatPrice(getTotalPrice())}");
    receipt.writeln("Address: $_deliveryAddress");
    return receipt.toString();
  }

  String _formatPrice(double price) => "₹${price.toStringAsFixed(2)}";
  String _formatAddons(List<Addons> addons) =>
      addons.map((a) => "${a.name} (${_formatPrice(a.price)})").join(", ");

  /// 🔁 Convert local cart → Firestore format (List<user_data.CartItem>)
  List<user_data.CartItem> _convertCartToFirestoreFormat(List<CartItem> localCart) {
    return localCart.map((item) {
      return user_data.CartItem(
        id: item.food.name, // Use food name or a unique ID
        name: item.food.name,
        price: item.food.price,
        quantity: item.quantity,
        addons: item.selectedAddons.map((a) => a.name).toList(),
        imageUrl: item.food.imagePath,
      );
    }).toList();
  }
}
