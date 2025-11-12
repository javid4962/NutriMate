import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_mate/pages/home_page.dart';
import 'package:nutri_mate/pages/profile_features.dart';
import 'package:nutri_mate/pages/verify_email_page.dart';
import 'package:nutri_mate/pages/onboarding_page.dart';
import 'package:nutri_mate/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _getInitialScreen(User user) async {
    // 1️⃣ Email verification check
    if (!user.emailVerified) return const VerifyEmailPage();

    // 2️⃣ Fetch user data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();

    // 3️⃣ No profile features → go to setup
    if (data == null || data['profileFeatures'] == null) {
      return const ProfileFeaturesPage();
    }

    // 4️⃣ Profile done, but onboarding not completed
    if (data['hasCompletedOnboarding'] == false) {
      return const OnboardingPage();
    }

    // 5️⃣ Everything done → go home
    return const HomePage();
  }

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
            child = FutureBuilder<Widget>(
              future: _getInitialScreen(user),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (futureSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading user data: ${futureSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return futureSnapshot.data ?? const HomePage();
                }
              },
            );
          } else {
            child = const LoginOrRegister();
          }

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
