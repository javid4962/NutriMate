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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
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
