import 'package:flutter/material.dart';
import 'package:nutri_mate/services/database/firestore.dart';
import 'package:provider/provider.dart';

import '../components/my_receipt.dart';
import '../models/restaurant.dart';

class DeliveryProgressPage extends StatefulWidget {
  const DeliveryProgressPage({super.key});

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  // get access to db
  FirestoreService db = FirestoreService();

  @override
  void initState() {
    super.initState();
  //   submit order to firestore
    String receipt = context.read<Restaurant>().displayCartReceipt();
    db.saveOrderToDatabase(receipt);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery")),
      bottomNavigationBar: _buildBottomNavBar(context),

      body: Column(children: [MyReceipt()]),
    );
  }

  //   Custom Nav bar for messaging/calling
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 100,
      // margin: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,

        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          // person Profile
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              // borderRadius: BorderRadius.circular(10)
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
          ),
          const SizedBox(width: 10),

          //   delivery person detials
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Javid",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Text(
                "Delivery Boy",
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          Spacer(),
          //
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                child: IconButton(onPressed: () {}, icon: Icon(Icons.message_outlined),color: Theme.of(context).colorScheme.primary,),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                child: IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined),color: Colors.green,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
