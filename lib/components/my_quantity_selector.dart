import 'package:flutter/material.dart';

import '../models/food.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Food food;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({super.key, required this.quantity, required this.food, required this.onIncrement, required this.onDecrement });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(50)
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // decrement button
          GestureDetector(
            child: Icon(Icons.remove,size: 20, color: Theme.of(context).colorScheme.primary,),
            onTap: onDecrement,
          ),

        //   quantity count value
          Padding(padding: EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 20,
            child: Center(
              child: Text(quantity.toString()),
            ),
          ),
          ),

        //   increment button
          GestureDetector(
            child: Icon(Icons.add,size: 20, color: Theme.of(context).colorScheme.primary,),
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}
