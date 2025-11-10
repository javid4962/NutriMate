import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_drawer_tile.dart';
import 'package:nutri_mate/pages/settings_page.dart';
import 'package:nutri_mate/pages/order_page.dart'; // ✅ import the OrderPage
import 'package:nutri_mate/services/auth/auth_services.dart';
import 'package:nutri_mate/services/auth/auth_gate.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authService = AuthServices();
      await authService.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 🧱 Drawer Header Icon
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Icon(Icons.restaurant_menu, size: 80, color: Theme.of(context).colorScheme.primary),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.all(25),
            child: Divider(color: Theme.of(context).colorScheme.secondary),
          ),

          // 🏠 Home
          MyDrawerTile(
            text: 'H O M E',
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),

          // 🧾 My Orders
          MyDrawerTile(
            text: 'M Y  O R D E R S',
            icon: Icons.receipt_long,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderPage()),
              );
            },
          ),

          // ⚙️ Settings
          MyDrawerTile(
            text: 'S E T T I N G S',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),

          const Spacer(),

          // 🚪 Logout
          MyDrawerTile(
            text: 'L O G O U T',
            icon: Icons.logout,
            onTap: () => logout(context),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
