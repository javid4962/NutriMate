import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 25, right: 25, top: 50),
    child: Center(
      child: Column(
        children: [
          Text("Thank you for ordering"),
          const SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(8)
            ),
            padding: EdgeInsets.all(25),
            child: Consumer<Restaurant>(builder: (context, restaurant, child)=> Text(restaurant.displayCartReceipt())),
          ),
          const SizedBox(height: 10,),

          Text("Estimated Delivery Time: 00:00"),
        ]
      ),
    ));
  }
}
