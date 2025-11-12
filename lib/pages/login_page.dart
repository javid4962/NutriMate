import 'package:flutter/material.dart';
import 'package:nutri_mate/components/my_button.dart';
import 'package:nutri_mate/components/my_textfield.dart';
import 'package:nutri_mate/services/auth/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_mate/pages/onboarding_page.dart';
import 'package:nutri_mate/pages/home_page.dart';


class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  // password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  // login method
  void login() async {
    if (_formKey.currentState!.validate()) {
      final _authService = AuthServices();
      try {
        await _authService.signInWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        // ✅ After successful login, decide where to go
        final prefs = await SharedPreferences.getInstance();
        final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

        if (mounted) {
          if (seenOnboarding) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingPage()),
            );
          }
        }
      } catch (e) {
        String message = e.toString();

        // 🎯 Friendly message mapping
        if (message.contains("wrong-password")) {
          message = "The password you entered is incorrect. Please try again.";
        } else if (message.contains("user-not-found")) {
          message = "No account found with this email. Please register first.";
        } else if (message.contains("invalid-email")) {
          message = "Please enter a valid email address.";
        } else if (message.contains("user-disabled")) {
          message = "This account has been disabled. Contact support for help.";
        } else if (message.contains("too-many-requests")) {
          message = "Too many failed attempts. Please try again later.";
        } else if (message.contains("network-request-failed")) {
          message = "Network error. Check your internet connection.";
        } else {
          message = "Authentication failed. Please check your credentials.";
        }

        // 🧠 Custom Stylish Error Dialog
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.all(30),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent.shade200,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Login Failed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("OK"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open_rounded, size: 100, color: Theme.of(context).colorScheme.inversePrimary),
                const SizedBox(height: 25),
                Text("Food Delivery App",
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary)),
                const SizedBox(height: 25),

                MyTextField(
                  controller: emailController,
                  hintText: 'Enter Email here',
                  labelText: "Email",
                  obscureText: false,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter Password',
                  labelText: "Password",
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 25),
                MyButton(onTap: login, text: 'Sign In'),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a Member?", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text("Register now",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
