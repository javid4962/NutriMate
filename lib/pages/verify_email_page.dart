import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_mate/pages/home_page.dart';
import 'package:nutri_mate/pages/profile_features.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // get initial verification status
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // 🔁 check every 5 seconds
      timer = Timer.periodic(const Duration(seconds: 5), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ✅ Send verification email
  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      setState(() => canResendEmail = true);
    } catch (e) {
      print("Error sending verification email: $e");
    }
  }

  // ✅ Check if email is verified
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser!;

    setState(() {
      isEmailVerified = user.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();

      // 🔥 Update Firestore to reflect verified email
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({
        'isEmailVerified': true,
        'updatedAt': Timestamp.now(),
      });

      // 🧠 Check if profileFeatures already exist
      final userDoc = await userRef.get();
      final hasProfile =
          userDoc.exists && userDoc.data()?['profileFeatures'] != null;

      // ✅ Redirect based on profile completion
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
            hasProfile ? const HomePage() : const ProfileFeaturesPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify Your Email')),
    body: Center(
      child: isEmailVerified
          ? const Text("✅ Email verified! Redirecting...")
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.email_outlined, size: 80),
          const SizedBox(height: 20),
          const Text(
            "A verification link has been sent to your email.\nPlease verify to continue.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Resend Email'),
            onPressed: canResendEmail ? sendVerificationEmail : null,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Cancel / Back to Login"),
          ),
        ],
      ),
    ),
  );
}
