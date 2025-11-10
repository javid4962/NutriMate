import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_mate/pages/home_page.dart';
import 'package:nutri_mate/pages/verify_email_page.dart';
import 'package:nutri_mate/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Widget child;
          if (snapshot.hasData) {
            final user = snapshot.data!;
            child = user.emailVerified
                ? const HomePage()
                : const VerifyEmailPage();
          } else {
            child = const LoginOrRegister();
          }

          // ✨ Smooth fade transition
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }
}
