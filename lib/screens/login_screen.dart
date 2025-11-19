import 'package:firebcrudapp/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Fluttertoast.showToast(msg: "Login Successful");

      // Navigate to HomeScreen after successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Login Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. App Icon/Logo Area
              Icon(
                Icons.task_alt,
                color: theme.primaryColor,
                size: 90,
              ),
              const SizedBox(height: 16),
              
              // 2. App Title/Slogan
              Text(
                "Task Manager",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "Your daily productivity hub.",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 80),

              // 3. Instruction Text
              Text(
                "Sign in to access your tasks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 30),

              // 4. Enhanced Google Sign-In Button (Themed Card Look)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: Image.network(
                    'https://imgs.search.brave.com/pHwrj8EiLQx_3BwmSlv2BMoBeTrnxWjwn2AzmhN8VsQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/aWNvbnNjb3V0LmNv/bS9pY29uL3ByZW1p/dW0vcG5nLTI1Ni10/aHVtYi9tYW5hZ2Vy/LWljb24tc3ZnLWRv/d25sb2FkLXBuZy0x/MDY0NTU4OC5wbmc_/Zj13ZWJwJnc9MTI4',
                    height: 24,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(
                      color: isDark ? Colors.blueGrey : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: signInWithGoogle,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}