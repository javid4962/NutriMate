
import 'package:flutter/material.dart';

import '../models/food.dart';

class FoodTile extends StatelessWidget {
  final Food food;
  final Function() onTap;
  // void Funtion() onTap;
  const FoodTile({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // food details
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.name),
                      Text(
                        "\u20B9 ${food.price.toString()}",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 10),
                      Text(food.description, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                    ],
                  ),
                ),
                const SizedBox(width: 15,),
                //   food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:Container(
                  width: 150,
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Image.asset(
                    // 1. Check for a valid path
                    (food.imagePath?.isEmpty ?? true)
                        ? 'lib/images/default/loading.gif' // Use default GIF
                        : food.imagePath!,

                    fit: BoxFit.cover,

                    // 2. Handle loading errors
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      // If the food.imagePath fails to load,
                      // return the default GIF here as well.
                      return Image.asset(
                        'lib/images/default/loading.gif',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                ),
                // Image.asset(food.imagePath, width: 100, height: 100,)
              ],
            ),
          ),
        ),

        //   Divider
        Divider(color: Theme.of(context).colorScheme.secondary, indent: 25, endIndent: 25),
      ],
    );
  }
}
