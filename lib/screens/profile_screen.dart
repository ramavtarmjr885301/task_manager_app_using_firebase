// Filename: profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart'; // Import to access MyApp's state
import 'login_screen.dart'; // Import the login screen for navigation

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // 1. Sign out from Firebase and Google
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    
    Fluttertoast.showToast(msg: "Logged Out");
    
    // 2. Navigate to login screen
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Profile"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. User Profile Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? "Guest User",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "No Email",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Text("APP SETTINGS", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
          const Divider(),

          // 2. Theme Mode Toggle (IMPLEMENTED HERE)
          ListTile(
            leading: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode, 
                        color: isDarkTheme ? Colors.yellow : Theme.of(context).primaryColor),
            title: Text(isDarkTheme ? "Dark Mode" : "Light Mode"),
            subtitle: const Text("Change application appearance"),
            trailing: Switch(
              value: isDarkTheme,
              onChanged: (value) {
                // Access the state in main.dart to toggle the theme
                MyApp.of(context).toggleTheme(value);
              },
            ),
          ),

          const Divider(),
          const SizedBox(height: 20),

          // 3. Logout Button 
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}