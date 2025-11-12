import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:nutri_mate/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  bool _updating = false;

  Future<void> _completeOnboarding() async {
    setState(() => _updating = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();

      // Save locally to prevent showing onboarding again if offline
      await prefs.setBool('seenOnboarding', true);

      // ✅ Update Firestore if logged in
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'hasCompletedOnboarding': true});
      }
    } catch (e) {
      debugPrint("Error updating onboarding status: $e");
    } finally {
      setState(() => _updating = false);

      // ✅ Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // 📜 Onboarding pages
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              OnboardSlide(
                imagePath: 'lib/images/onboarding/onboard1.png',
                title: 'Welcome to NutriMate',
                description:
                    'Your smart food companion for healthy eating and personalized diet plans.',
              ),
              OnboardSlide(
                imagePath: 'lib/images/onboarding/onboard2.png',
                title: 'Discover Nutritious Meals',
                description:
                    'Find balanced meal plans curated by experts — tailored to your preferences.',
              ),
              OnboardSlide(
                imagePath: 'lib/images/onboarding/onboard3.png',
                title: 'Track & Improve Your Health',
                description:
                    'Stay on top of your goals with real-time meal tracking and AI-based suggestions.',
              ),
            ],
          ),

          // ⚡ Bottom controls
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ⏩ Skip
                GestureDetector(
                  onTap: () => _controller.jumpToPage(2),
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // 🔘 Dots
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),

                // ➡️ Next or Done
                onLastPage
                    ? GestureDetector(
                        onTap: _updating ? null : _completeOnboarding,
                        child: _updating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Get Started",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 📸 Individual onboarding slides
class OnboardSlide extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardSlide({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🖼️ Image
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 🧾 Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 📖 Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
