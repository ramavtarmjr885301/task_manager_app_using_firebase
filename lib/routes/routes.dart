import 'package:firebcrudapp/screens/add_task_screen.dart';
import 'package:firebcrudapp/screens/category_filter_screen.dart';
import 'package:firebcrudapp/screens/edit_task_screen.dart';
import 'package:firebcrudapp/screens/home_screen.dart';
import 'package:firebcrudapp/screens/login_screen.dart';
import 'package:firebcrudapp/routes/routes_name.dart';
import 'package:firebcrudapp/screens/onboarding_screen.dart';
import 'package:firebcrudapp/screens/profile_screen.dart';
import 'package:firebcrudapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case RoutesName.addTaskScreen:
        return MaterialPageRoute(builder: (context) => AddTaskScreen());
      case RoutesName.editTaskScreen:
        return MaterialPageRoute(
          builder: (context) =>
              EditTaskScreen(taskId: settings.arguments as String),
        );
      case RoutesName.categoryFilterScreen:
        return MaterialPageRoute(
          builder: (context) {
            return CategoryFilterScreen(
              onCategorySelected: (category) {},
              currentCategory: 'All',
            );
          },
        );
      case RoutesName.profileScreen:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case RoutesName.onboardingScreen:
        return MaterialPageRoute(builder: (context) => OnboardingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) {
            return const Scaffold(
              body: Center(child: Text("No Routes defined")),
            );
          },
        );
    }
  }
}
