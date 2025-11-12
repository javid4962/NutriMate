import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../models/user_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // // Controllers
  // final _ageController = TextEditingController();
  // final _heightController = TextEditingController();
  // final _weightController = TextEditingController();
  // final _breakfastController = TextEditingController();
  // final _lunchController = TextEditingController();
  // final _snacksController = TextEditingController();
  // final _dinnerController = TextEditingController();

  // String? _selectedGender;
  // String? _selectedActivity;
  // String? _selectedDiet;
  // String? _selectedGoal;
  // String? _selectedCuisine;

  // bool _loading = true;
  // bool _saving = false;

  // Dropdown options
  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> activities = [
    "Sedentary",
    "Lightly Active",
    "Moderately Active",
    "Very Active",
  ];
  final List<String> diets = [
    "Omnivore",
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Keto",
  ];
  final List<String> goals = [
    "Weight Loss",
    "Weight Gain",
    "Maintain Weight",
    "Muscle Gain",
  ];
  final List<String> cuisines = [
    "South Indian",
    "North Indian",
    "Continental",
    "Asian",
    "Mediterranean",
  ];

  final List<String> healthConditions = [
    "Diabetes",
    "Hypertension",
    "Thyroid",
    "PCOS",
    "Obesity",
    "Heart Disease",
    "Anemia",
  ];
  final List<String> allergies = ["Lactose", "Gluten", "Peanuts", "Seafood"];
  final List<String> tastePreferences = [
    "Spicy",
    "Less Oil",
    "Mild",
    "High Protein",
    "Low Salt",
  ];

  final List<String> _selectedConditions = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedTastes = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ✅ Load user profile from Firestore safely
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();

    if (data != null && data['profileFeatures'] != null) {
      final profile = ProfileFeatures.fromMap(
        Map<String, dynamic>.from(data['profileFeatures']),
      );

      // setState(() {
      //   _ageController.text = profile.age.toString();
      //   _heightController.text = profile.heightCm.toString();
      //   _weightController.text = profile.weightKg.toString();

      //   // ✅ Validate dropdown values against list
      //   _selectedGender = genders.contains(profile.gender)
      //       ? profile.gender
      //       : null;
      //   _selectedActivity = activities.contains(profile.activityLevel)
      //       ? profile.activityLevel
      //       : null;
      //   _selectedDiet = diets.contains(profile.dietaryPreference)
      //       ? profile.dietaryPreference
      //       : null;
      //   _selectedGoal = goals.contains(profile.goal) ? profile.goal : null;
      //   _selectedCuisine = cuisines.contains(profile.cuisinePreference)
      //       ? profile.cuisinePreference
      //       : null;

      //   _selectedConditions.addAll(profile.healthConditions);
      //   _selectedAllergies.addAll(profile.allergies);
      //   _selectedTastes.addAll(profile.tastePreference);

      //   _breakfastController.text =
      //       profile.mealTimings['breakfast'] ?? "08:00 AM";
      //   _lunchController.text = profile.mealTimings['lunch'] ?? "01:00 PM";
      //   _snacksController.text = profile.mealTimings['snacks'] ?? "05:00 PM";
      //   _dinnerController.text = profile.mealTimings['dinner'] ?? "08:00 PM";
      // });
    }

    // setState(() => _loading = false);
  }

  // ✅ Save updated profile
  // Future<void> _saveProfile() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _saving = true);

  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final age = int.tryParse(_ageController.text.trim()) ?? 0;
  //   final height = int.tryParse(_heightController.text.trim()) ?? 0;
  //   final weight = int.tryParse(_weightController.text.trim()) ?? 0;
  //   final bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;

  //   final updatedProfile = ProfileFeatures(
  //     age: age,
  //     gender: _selectedGender ?? '',
  //     heightCm: height,
  //     weightKg: weight,
  //     bmi: bmi,
  //     activityLevel: _selectedActivity ?? '',
  //     dietaryPreference: _selectedDiet ?? '',
  //     goal: _selectedGoal ?? '',
  //     lastUpdated: Timestamp.now(),
  //     healthConditions: _selectedConditions,
  //     allergies: _selectedAllergies,
  //     cuisinePreference: _selectedCuisine ?? '',
  //     tastePreference: _selectedTastes,
  //     mealTimings: {
  //       'breakfast': _breakfastController.text,
  //       'lunch': _lunchController.text,
  //       'snacks': _snacksController.text,
  //       'dinner': _dinnerController.text,
  //     },
  //   );

  //   await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
  //     'profileFeatures': updatedProfile.toMap(),
  //     'updatedAt': Timestamp.now(),
  //   });

  //   setState(() => _saving = false);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Profile updated successfully!"),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   }
  // }

  Widget _buildMultiSelect(
    String title,
    List<String> options,
    List<String> selectedList,
  ) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: options.map((opt) {
        final selected = selectedList.contains(opt);
        return CheckboxListTile(
          title: Text(opt),
          value: selected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedList.add(opt);
              } else {
                selectedList.remove(opt);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // body: _loading
      //     ? const Center(child: CircularProgressIndicator())
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🌗 Dark Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  CupertinoSwitch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🧠 Profile Form
          ],
        ),
      ),
    );
  }
}
