import 'food.dart';

class CartItem {
  Food food;
  List<Addons> selectedAddons = [];
  int quantity;

  CartItem({required this.food, required this.selectedAddons, required this.quantity});

  double get totalPrice {
    double addonPrice = selectedAddons.fold(0, (sum, addons) => sum + addons.price);
    return (food.price + addonPrice) * quantity;
  }
}
