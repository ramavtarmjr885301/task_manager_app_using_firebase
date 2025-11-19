// // Filename: onboarding_screen.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // For tracking if onboarding is seen
// import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For page dots

// import '../routes/routes_name.dart'; // To navigate to home screen

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   bool _isLastPage = false;

//   // Onboarding page data structure
//   final List<Map<String, String>> _onboardingPages = [
//     {
//       'image':
//           'https://imgs.search.brave.com/tKwehrc34C5sCl-8TNf94zLsuJ2OKOPmMvG72-xyoUk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wbGFu/dG9vcmdhbml6ZS5j/b20vd3AtY29udGVu/dC91cGxvYWRzLzIw/MjMvMDQvb3JnYW5p/emVkLWxpZmUtNS02/ODN4MTAyNC5wbmc', // Replace with your image
//       'title': 'Organize Your Life, Effortlessly',
//       'description':
//           'Keep track of every task, big or small. Never miss a deadline again with our intuitive manager.',
//     },
//     {
//       'image':
//           'https://imgs.search.brave.com/6aan0EJhLcLEp_-9iyB8CWC27yUghRCTgqbG_d9SsZY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zLndp/ZGdldC1jbHViLmNv/bS93ZWIvbm8yLzFk/YTMzYTgzY2ZhMWIx/MGM4OTc3NzU5NWMy/MTNhZDIzLnBuZw', // Replace with your image
//       'title': 'Smart Reminders, On Time',
//       'description':
//           'Get timely notifications for your most important tasks. Stay focused and productive.',
//     },
//     {
//       'image':
//           'https://imgs.search.brave.com/hw2oYSNYPvP6x40gTZJIDb0dHDrm-82ShCRsyncs9f0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93ZWVr/cGxhbi13d3cuczMu/dXMtZWFzdC0xLmFt/YXpvbmF3cy5jb20v/SG93JTIwdG8lMjBT/ZXQlMjBHb2FscyUy/MGFuZCUyMEFjaGll/dmUlMjBUaGVtJTIw/VGhyb3VnaCUyMERh/aWx5JTIwUGxhbm5p/bmcxJTIwKDkpLnBu/Zw', // Replace with your image
//       'title': 'Achieve Your Goals, Daily',
//       'description':
//           'Break down big projects into manageable steps. See your progress and celebrate your achievements!',
//     },
//   ];

//   // Function to mark onboarding as complete and navigate to home
//   Future<void> _onIntroEnd() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenOnboarding', true); // Mark as seen
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _isLastPage = index == _onboardingPages.length - 1;
//               });
//             },
//             itemCount: _onboardingPages.length,
//             itemBuilder: (context, index) {
//               final page = _onboardingPages[index];
//               return Container(
//                 color: Theme.of(
//                   context,
//                 ).scaffoldBackgroundColor, // Background color
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // --- Image Section ---
//                     Expanded(
//                       flex: 3,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20.0,
//                           vertical: 40.0,
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.network(
//                             page['image']!,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             // Placeholder for network image loading
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return Center(
//                                 child: CircularProgressIndicator(
//                                   value:
//                                       loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                       : null,
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) => Icon(
//                               Icons.broken_image,
//                               size: 100,
//                               color: Colors.grey,
//                             ), // Fallback for error
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),

//                     // --- Title Section ---
//                     Expanded(
//                       flex: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                         child: Column(
//                           children: [
//                             Text(
//                               page['title']!,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                             const SizedBox(height: 15),

//                             // --- Description Section ---
//                             Text(
//                               page['description']!,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Theme.of(
//                                   context,
//                                 ).textTheme.bodyMedium?.color?.withOpacity(0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               );
//             },
//           ),

//           // --- Bottom Navigation (Dots, Skip/Next/Done Buttons) ---
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20.0,
//                 vertical: 40.0,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Skip Button
//                   if (!_isLastPage)
//                     TextButton(
//                       onPressed: _onIntroEnd,
//                       child: Text(
//                         'Skip',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Theme.of(context).textTheme.bodySmall?.color,
//                         ),
//                       ),
//                     ),

//                   // Page Indicator Dots
//                   SmoothPageIndicator(
//                     controller: _pageController,
//                     count: _onboardingPages.length,
//                     effect: ExpandingDotsEffect(
//                       dotColor: Colors.grey,
//                       activeDotColor: Theme.of(context).primaryColor,
//                       dotHeight: 8,
//                       dotWidth: 8,
//                       expansionFactor: 4,
//                       spacing: 5.0,
//                     ),
//                   ),

//                   // Next/Done Button
//                   _isLastPage
//                       ? ElevatedButton(
//                           onPressed: _onIntroEnd,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 25,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: const Text(
//                             'Get Started',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         )
//                       : ElevatedButton(
//                           onPressed: () {
//                             _pageController.nextPage(
//                               duration: const Duration(milliseconds: 400),
//                               curve: Curves.easeIn,
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 25,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: const Text(
//                             'Next',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }
///////////
///
///
///
///
///
///
///
///
///
// Filename: onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For tracking if onboarding is seen
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For page dots
import 'package:firebase_auth/firebase_auth.dart'; // <<< ADDED IMPORT: For login status check

import '../routes/routes_name.dart'; // To navigate to home screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  // Onboarding page data structure (Image URLs preserved)
  final List<Map<String, String>> _onboardingPages = [
    {
      'image':
          'https://imgs.search.brave.com/tKwehrc34C5sCl-8TNf94zLsuJ2OKOPmMvG72-xyoUk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wbGFu/dG9vcmdhbml6ZS5j/b20vd3AtY29udGVu/dC91cGxvYWRzLzIw/MjMvMDQvb3JnYW5p/emVkLWxpZmUtNS02/ODN4MTAyNC5wbmc', // Replace with your image
      'title': 'Organize Your Life, Effortlessly',
      'description':
          'Keep track of every task, big or small. Never miss a deadline again with our intuitive manager.',
    },
    {
      'image':
          'https://imgs.search.brave.com/6aan0EJhLcLEp_-9iyB8CWC27yUghRCTgqbG_d9SsZY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zLndp/ZGdldC1jbHViLmNv/bS93ZWIvbm8yLzFk/YTMzYTgzY2ZhMWIx/MGM4OTc3NzU5NWMy/MTNhZDIzLnBuZw', // Replace with your image
      'title': 'Smart Reminders, On Time',
      'description':
          'Get timely notifications for your most important tasks. Stay focused and productive.',
    },
    {
      'image':
          'https://img.freepik.com/free-vector/ambition-abstract-concept-illustration-business-ambition-determination-setting-big-goal-making-fast-career-self-confident-getting-what-you-want-desire-success_335657-33.jpg', // Replace with your image
      'title': 'Achieve Your Goals, Daily',
      'description':
          'Break down big projects into manageable steps. See your progress and celebrate your achievements!',
    },
  ];

  // Function to mark onboarding as complete and determine final navigation
  Future<void> _onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true); // Mark as seen

    if (!mounted) return;

    // Check login status: If user is logged in (e.g., auto-login after Firebase setup), go home.
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, skip to home screen
      Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
    } else {
      // User is not logged in, go to login screen
      Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _onboardingPages.length - 1;
              });
            },
            itemCount: _onboardingPages.length,
            itemBuilder: (context, index) {
              final page = _onboardingPages[index];
              return Container(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor, // Background color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Image Section ---
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3.0,
                          vertical: 0.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            page['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // Placeholder for network image loading
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ), // Fallback for error
                          ),
                        ),
                      ),
                    ),
                    

                    // --- Title Section ---
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            

                            // --- Description Section ---
                            Text(
                              page['description']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withValues(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),

          // --- Bottom Navigation (Dots, Skip/Next/Done Buttons) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  if (!_isLastPage)
                    TextButton(
                      onPressed: _onIntroEnd, // <<< Calls function to check login and navigate
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),

                  // Page Indicator Dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingPages.length,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Theme.of(context).primaryColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 5.0,
                    ),
                  ),

                  // Next/Done Button
                  _isLastPage
                      ? ElevatedButton(
                          onPressed: _onIntroEnd, // <<< Calls function to check login and navigate
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}