import 'package:flutter/material.dart';

// The function signature for when a category is selected
typedef CategorySelectedCallback = void Function(String category);

class CategoryFilterScreen extends StatelessWidget {
  final CategorySelectedCallback onCategorySelected;
  final String currentCategory;
  
  // These categories should match those in add_task_screen.dart
  final List<String> _categories = [
    'All', // Add 'All' category for viewing all tasks
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter by Category"),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == currentCategory;
          
          return ListTile(
            leading: Icon(_getCategoryIcon(category)),
            title: Text(category),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              onCategorySelected(category);
              Navigator.pop(context); // Close the screen after selection
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.book;
      case 'Health':
        return Icons.favorite;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Other':
        return Icons.more_horiz;
      case 'All':
      default:
        return Icons.category;
    }
  }
}