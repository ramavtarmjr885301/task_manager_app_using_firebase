// import 'package:flutter/material.dart';

// // The function signature for when a category is selected
// typedef CategorySelectedCallback = void Function(String category);

// class CategoryFilterScreen extends StatelessWidget {
//   final CategorySelectedCallback onCategorySelected;
//   final String currentCategory;
  
//   // These categories should match those in add_task_screen.dart
//   final List<String> _categories = [
//     'All', // Add 'All' category for viewing all tasks
//     'Personal',
//     'Work',
//     'Study',
//     'Health',
//     'Shopping',
//     'Other',
//   ];

//   CategoryFilterScreen({
//     super.key,
//     required this.onCategorySelected,
//     required this.currentCategory,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Filter by Category"),
//       ),
//       body: ListView.builder(
//         itemCount: _categories.length,
//         itemBuilder: (context, index) {
//           final category = _categories[index];
//           final isSelected = category == currentCategory;
          
//           return ListTile(
//             leading: Icon(_getCategoryIcon(category)),
//             title: Text(category),
//             trailing: isSelected
//                 ? Icon(Icons.check, color: Theme.of(context).primaryColor)
//                 : null,
//             onTap: () {
//               onCategorySelected(category);
//               Navigator.pop(context); // Close the screen after selection
//             },
//           );
//         },
//       ),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Personal':
//         return Icons.person;
//       case 'Work':
//         return Icons.work;
//       case 'Study':
//         return Icons.book;
//       case 'Health':
//         return Icons.favorite;
//       case 'Shopping':
//         return Icons.shopping_cart;
//       case 'Other':
//         return Icons.more_horiz;
//       case 'All':
//       default:
//         return Icons.category;
//     }
//   }
// }
/////
///
///
///
///
///
///
///
///
import 'package:flutter/material.dart';

// The function signature for when a category is selected
typedef CategorySelectedCallback = void Function(String category);

class CategoryFilterScreen extends StatelessWidget {
  final CategorySelectedCallback onCategorySelected;
  final String currentCategory;
  
  final List<String> _categories = const [
    'All', 
    'Personal',
    'Work',
    'Study',
    'Health',
    'Shopping',
    'Other',
  ];

  CategoryFilterScreen({
    super.key,
    required this.onCategorySelected,
    required this.currentCategory,
  });

  // Helper to assign a relevant icon to each category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.school;
      case 'Health':
        return Icons.favorite;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'All':
        return Icons.dashboard;
      case 'Other':
      default:
        return Icons.more_horiz;
    }
  }

  // Helper to assign a color to the category icon and indicator
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.blueAccent;
      case 'Work':
        return Colors.purple;
      case 'Study':
        return Colors.green;
      case 'Health':
        return Colors.pink;
      case 'Shopping':
        return Colors.orange;
      case 'All':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter by Category"),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select a category to refine your task list.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey, // Use a fixed grey for supporting text clarity
              ),
            ),
          ),
          ..._categories.map((category) {
            final isSelected = category == currentCategory;
            final color = _getCategoryColor(category);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              elevation: isSelected ? 4 : 1, // Increased elevation when selected
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                // Visually highlight the selected card with a border
                side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
              ),
              child: InkWell( // Use InkWell for better visual feedback on tap
                onTap: () {
                  onCategorySelected(category);
                  Navigator.pop(context); 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(category),
                      color: color,
                      size: 28,
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        // Match text color to the accent color when selected
                        color: isSelected ? color : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: color, size: 24)
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}