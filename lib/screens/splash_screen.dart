import 'package:firebcrudapp/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // <<< ADDED IMPORT

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  // Set a standard splash duration
  static const int _splashDuration = 2; 
  
  @override
  void initState() {
    super.initState();
    _startAppInitialization();
  }
  
  // Combines the timer and the status check for a smoother transition
  void _startAppInitialization() async {
    // Start the timer and the status check simultaneously
    await Future.wait([
      Future.delayed(const Duration(seconds: _splashDuration)), // Ensures minimum display time
      _checkAndNavigate(), // Checks Onboarding and Firebase status
    ]);
  }

  Future<void> _checkAndNavigate() async {
    // 1. Get shared preferences and check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    // 2. Check Firebase login status
    User? user = FirebaseAuth.instance.currentUser;
    
    // Ensure context is still valid before navigating
    if (!mounted) return; 

    if (!hasSeenOnboarding) {
      // >>> First-time user: Go to onboarding screens
      Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
    } else if (user != null) {
      // Returning user, logged in: Go to home screen
      Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
    } else {
      // Returning user, logged out: Go to login screen
      Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
    }
  }

  // NOTE: The previous checkLoginStatus method is now entirely handled by _checkAndNavigate

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use a background color theme that fits the brand
        color: Theme.of(context).primaryColor, 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. App Icon or Logo
              const Icon(
                Icons.task_alt, 
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 20),
              
              // 2. App Title
              const Text(
                "Task Manager",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 50),
              
              // 3. Loading Indicator
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 8),

              // 4. Status Text
              const Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}