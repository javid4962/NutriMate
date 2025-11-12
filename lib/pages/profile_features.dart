import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_mate/services/user/user_service.dart';
import 'package:nutri_mate/pages/home_page.dart';

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

  String? _selectedGender;
  String? _selectedActivity;
  String? _selectedDiet;
  String? _selectedGoal;

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

  bool _loading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await UserService().updateUserProfileFeatures(
      uid: user.uid,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender!,
      heightCm: int.tryParse(_heightController.text.trim()) ?? 0,
      weightKg: int.tryParse(_weightController.text.trim()) ?? 0,
      activityLevel: _selectedActivity!,
      dietaryPreference: _selectedDiet!,
      goal: _selectedGoal,
    );

    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
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
              const Text(
                "Tell us about yourself 🧠",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // AGE
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter your age" : null,
              ),
              const SizedBox(height: 15),

              // GENDER
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                validator: (val) =>
                val == null ? "Please select your gender" : null,
              ),
              const SizedBox(height: 15),

              // HEIGHT
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter your height" : null,
              ),
              const SizedBox(height: 15),

              // WEIGHT
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter your weight" : null,
              ),
              const SizedBox(height: 15),

              // ACTIVITY LEVEL
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Activity Level",
                  border: OutlineInputBorder(),
                ),
                value: _selectedActivity,
                items: activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedActivity = val),
                validator: (val) =>
                val == null ? "Select your activity level" : null,
              ),
              const SizedBox(height: 15),

              // DIETARY PREFERENCE
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Dietary Preference",
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiet,
                items: diets
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDiet = val),
                validator: (val) =>
                val == null ? "Select your dietary preference" : null,
              ),
              const SizedBox(height: 15),

              // GOAL
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Health Goal",
                  border: OutlineInputBorder(),
                ),
                value: _selectedGoal,
                items: goals
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGoal = val),
                validator: (val) => val == null ? "Select your goal" : null,
              ),
              const SizedBox(height: 30),

              // SUBMIT BUTTON
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
