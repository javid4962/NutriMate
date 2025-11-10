import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:pay/pay.dart';
import 'package:nutri_mate/components/my_button.dart';
import 'package:nutri_mate/pages/delivery_progress_page.dart';

import 'package:provider/provider.dart';
import '../models/restaurant.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Credit Card Variables
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool showBackView = false;

  // UPI Apps
  String selectedUPIApp = '';
  final List<Map<String, dynamic>> upiApps = [
    {'name': 'Google Pay', 'icon': Icons.account_balance_wallet},
    {'name': 'PhonePe', 'icon': Icons.phone_android},
    {'name': 'Paytm', 'icon': Icons.payment},
    {'name': 'BHIM UPI', 'icon': Icons.account_balance},
  ];

  // Pay package items (Google Pay)
  List<PaymentItem> getPaymentItems(double totalPrice) {
    return [PaymentItem(label: 'Total', amount: totalPrice.toStringAsFixed(2), status: PaymentItemStatus.final_price)];
  }

  PaymentConfiguration? _googlePayConfig;
  bool _isGooglePayReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load Google Pay configuration asynchronously
    PaymentConfiguration.fromAsset('payments/gpay_config.json').then((config) {
      setState(() {
        _googlePayConfig = config;
        _isGooglePayReady = true;
      });
    });
  }

  void confirmPayment(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text("Proceed with $method payment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryProgressPage()));
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void userTappedPay() {
    if (formKey.currentState!.validate()) {
      confirmPayment("Credit Card");
    }
  }

  void userTappedUPIPay() {
    if (selectedUPIApp.isNotEmpty) {
      confirmPayment(selectedUPIApp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a UPI app to continue."), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void onGooglePayResult(paymentResult) {
    debugPrint("✅ Google Pay Payment result: $paymentResult");
    confirmPayment("Google Pay");
  }

  // CREDIT CARD TAB
  Widget buildCreditCardTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: showBackView,
              onCreditCardWidgetChange: (_) {},
              cardBgColor: const Color(0xFF192F6A),
            ),
            CreditCardForm(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: (data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                });
              },
              formKey: formKey,
            ),
            const SizedBox(height: 40),
            MyButton(onTap: userTappedPay, text: "Pay  via Card"),
          ],
        ),
      ),
    );
  }

  // // UPI TAB
  // Widget buildUPITab() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text("Select UPI App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         const SizedBox(height: 15),
  //         Wrap(
  //           spacing: 10,
  //           runSpacing: 10,
  //           children: upiApps.map((app) {
  //             bool isSelected = selectedUPIApp == app['name'];
  //             return GestureDetector(
  //               onTap: () => setState(() => selectedUPIApp = app['name']),
  //               child: AnimatedContainer(
  //                 duration: const Duration(milliseconds: 200),
  //                 width: 150,
  //                 height: 60,
  //                 decoration: BoxDecoration(
  //                   color: isSelected
  //                       ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
  //                       : Theme.of(context).colorScheme.surface,
  //                   border: Border.all(
  //                     color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
  //                   ),
  //                   borderRadius: BorderRadius.circular(15),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [Icon(app['icon'], size: 26), const SizedBox(width: 10), Text(app['name'])],
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //         const SizedBox(height: 40),
  //         MyButton(
  //           onTap: userTappedUPIPay,
  //           text: selectedUPIApp.isEmpty ? "Select UPI App" : "Pay via $selectedUPIApp",
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // GOOGLE PAY TAB
  Widget buildWalletTab(BuildContext context) {
    final restaurant = Provider.of<Restaurant>(context, listen: false);
    final totalPrice = restaurant.getTotalPrice();

    if (!_isGooglePayReady || _googlePayConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Pay using Google Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // ✅ Google Pay Button with dynamic total
          GooglePayButton(
            paymentConfiguration: _googlePayConfig!,
            paymentItems: getPaymentItems(totalPrice),
            type: GooglePayButtonType.pay,
            onPaymentResult: onGooglePayResult,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
          ),

          const SizedBox(height: 15),
          Text(
            "Total: ₹${totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Card"),
            Tab(text: "Google Pay"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildCreditCardTab(),  buildWalletTab(context)],
      ),
    );
  }
}
