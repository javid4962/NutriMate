import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:nutri_mate/pages/home_page.dart'; // navigate after onboarding

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Controller for page view
  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // PAGES
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2); // last page index
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

          // DOT INDICATOR + NEXT/BUTTON
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip
                GestureDetector(
                  onTap: () => _controller.jumpToPage(2),
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // Dot indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),

                // Next or Done
                onLastPage
                    ? GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seenOnboarding', true);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },

                  child: const Text(
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

// SLIDE WIDGET (Reusable)
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
         Container(
           height: 500,
           width: double.infinity,
           decoration: BoxDecoration(
             image: DecorationImage(image: AssetImage(imagePath),fit: BoxFit.cover)
           ),
         ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
