import 'package:firebcrudapp/add_task_screen.dart';
import 'package:firebcrudapp/category_filter_screen.dart';
import 'package:firebcrudapp/edit_task_screen.dart';
import 'package:firebcrudapp/home_screen.dart';
import 'package:firebcrudapp/login_screen.dart';
import 'package:firebcrudapp/routes/routes_name.dart';
import 'package:firebcrudapp/splash_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case RoutesName.addTaskScreen:
        return MaterialPageRoute(builder: (context) => const AddTaskScreen());
      case RoutesName.editTaskScreen:
        return MaterialPageRoute(
          builder: (context) =>
              EditTaskScreen(taskId: settings.arguments as String),
        );
      case RoutesName.categoryFilterScreen:
        // Arguments needed: (CategorySelectedCallback, currentCategory)
        // We will use Navigator.push directly in home_screen to pass these complex arguments.
        // So, we can leave this route case for simple arguments or dynamic routes for now,
        // but we still register the name.
        return MaterialPageRoute(
          builder: (context) {
            // Placeholder: The actual navigation happens in HomeScreen
            return CategoryFilterScreen(
              onCategorySelected: (category) {},
              currentCategory: 'All',
            );
          },
        );
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
