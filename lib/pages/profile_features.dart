import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_mate/services/user/user_service.dart';
import 'package:nutri_mate/pages/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileFeaturesPage extends StatefulWidget {
  const ProfileFeaturesPage({super.key});

  @override
  State<ProfileFeaturesPage> createState() => _ProfileFeaturesPageState();
}

class _ProfileFeaturesPageState extends State<ProfileFeaturesPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _breakfastController = TextEditingController(text: "08:00 AM");
  final _lunchController = TextEditingController(text: "01:00 PM");
  final _snacksController = TextEditingController(text: "05:00 PM");
  final _dinnerController = TextEditingController(text: "08:00 PM");

  String? _selectedGender;
  String? _selectedActivity;
  String? _selectedDiet;
  String? _selectedGoal;
  String? _selectedCuisine;

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> activities = [
    "Sedentary",
    "Lightly Active",
    "Moderately Active",
    "Very Active"
  ];
  final List<String> diets = [
    "Omnivore",
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Keto"
  ];
  final List<String> goals = [
    "Weight Loss",
    "Weight Gain",
    "Maintain Weight",
    "Muscle Gain"
  ];
  final List<String> cuisines = [
    "South Indian",
    "North Indian",
    "Continental",
    "Asian",
    "Mediterranean"
  ];

  // Multi-select fields
  final List<String> healthConditions = [
    "Diabetes",
    "Hypertension",
    "Thyroid",
    "PCOS",
    "Obesity",
    "Heart Disease",
    "Anemia"
  ];
  final List<String> allergies = ["Lactose", "Gluten", "Peanuts", "Seafood"];
  final List<String> tastePreferences = [
    "Spicy",
    "Less Oil",
    "Mild",
    "High Protein",
    "Low Salt"
  ];

  final List<String> _selectedConditions = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedTastes = [];

  bool _loading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final height = int.tryParse(_heightController.text.trim()) ?? 0;
    final weight = int.tryParse(_weightController.text.trim()) ?? 0;
    final bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;

    // ✅ Save extended profile
    await UserService().updateUserProfileFeatures(
      uid: user.uid,
      age: age,
      gender: _selectedGender!,
      heightCm: height,
      weightKg: weight,
      activityLevel: _selectedActivity!,
      dietaryPreference: _selectedDiet!,
      goal: _selectedGoal!,
      extraData: {
        'bmi': bmi,
        'healthConditions': _selectedConditions,
        'allergies': _selectedAllergies,
        'cuisinePreference': _selectedCuisine ?? "",
        'tastePreference': _selectedTastes,
        'mealTimings': {
          'breakfast': _breakfastController.text,
          'lunch': _lunchController.text,
          'snacks': _snacksController.text,
          'dinner': _dinnerController.text,
        },
      },
    );

    // ✅ Mark onboarding as "not completed"
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'hasCompletedOnboarding': false,
    });

    setState(() => _loading = false);

    // ✅ Navigate to onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

  Widget _buildMultiSelect(String title, List<String> options, List<String> selectedList) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tell us about yourself 🧠",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Enter age" : null,
              ),
              const SizedBox(height: 15),

              // Gender
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? "Select gender" : null,
              ),
              const SizedBox(height: 15),

              // Height
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Enter height" : null,
              ),
              const SizedBox(height: 15),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Enter weight" : null,
              ),
              const SizedBox(height: 15),

              // Activity Level
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Activity Level",
                  border: OutlineInputBorder(),
                ),
                value: _selectedActivity,
                items: activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedActivity = v),
                validator: (v) => v == null ? "Select activity" : null,
              ),
              const SizedBox(height: 15),

              // Dietary Preference
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Dietary Preference",
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiet,
                items: diets
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDiet = v),
                validator: (v) => v == null ? "Select diet" : null,
              ),
              const SizedBox(height: 15),

              // Goal
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Health Goal",
                  border: OutlineInputBorder(),
                ),
                value: _selectedGoal,
                items: goals
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGoal = v),
                validator: (v) => v == null ? "Select goal" : null,
              ),
              const SizedBox(height: 15),

              // Cuisine Preference
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Cuisine Preference",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCuisine,
                items: cuisines
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCuisine = v),
              ),
              const SizedBox(height: 15),

              // Multi-selects
              _buildMultiSelect("Health Conditions", healthConditions, _selectedConditions),
              _buildMultiSelect("Allergies", allergies, _selectedAllergies),
              _buildMultiSelect("Taste Preferences", tastePreferences, _selectedTastes),

              const SizedBox(height: 15),
              const Text("Meal Timings 🕒", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _breakfastController, decoration: const InputDecoration(labelText: "Breakfast Time")),
              TextFormField(controller: _lunchController, decoration: const InputDecoration(labelText: "Lunch Time")),
              TextFormField(controller: _snacksController, decoration: const InputDecoration(labelText: "Snacks Time")),
              TextFormField(controller: _dinnerController, decoration: const InputDecoration(labelText: "Dinner Time")),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _saveProfile,
                  icon: const Icon(Icons.check_circle_outline),
                  label: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Profile"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
