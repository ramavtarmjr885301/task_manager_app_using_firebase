// import 'package:firebcrudapp/routes/routes_name.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'login_screen.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../main.dart'; // Import to access MyApp's state
// import 'category_filter_screen.dart'; // Import the new screen

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final User? _currentUser = FirebaseAuth.instance.currentUser;
//   final CollectionReference _itemsCollection = FirebaseFirestore.instance
//       .collection("tasks"); // Renamed collection

//   // Filter state
//   String _currentFilter = 'All'; // Status filter (All, pending, in-progress, completed)
//   String _currentCategoryFilter = 'All'; // Category filter (All, Personal, Work, etc.)
//   String _currentSort = 'createdAt';

//   // Available filters and sort options
//   final List<String> _statusFilters = [
//     'All',
//     'pending',
//     'in-progress',
//     'completed',
//   ];
//   final Map<String, Color> _priorityColors = {
//     'high': Colors.red,
//     'medium': Colors.orange,
//     'low': Colors.green,
//   };

//   CollectionReference get _userTasksCollection {
//     if (_currentUser == null) {
//       throw Exception('User not logged in');
//     }
//     // Use 'user_tasks' subcollection
//     return _itemsCollection.doc(_currentUser!.uid).collection('user_tasks');
//   }

//   // >>> NEW: Function to handle category selection from the filter screen
//   void _handleCategorySelection(String category) {
//     setState(() {
//       _currentCategoryFilter = category;
//     });
//   }

//   Future<void> logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Fluttertoast.showToast(msg: "Logged Out");
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => LoginScreen()),
//     );
//   }

//   _deleteTask(DocumentSnapshot doc) async {
//     try {
//       await _userTasksCollection.doc(doc.id).delete();
//       Fluttertoast.showToast(msg: "Task deleted");
//       // TODO: #1 - Implement Push Notification for task deletion
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error deleting task: $e");
//     }
//   }

//   _toggleTaskStatus(DocumentSnapshot doc, bool? isCompleted) async {
//     if (doc.exists) {
//       final newStatus = isCompleted == true ? 'completed' : 'pending';
//       try {
//         await _userTasksCollection.doc(doc.id).update({
//           'status': newStatus,
//           'completedAt': isCompleted == true
//               ? FieldValue.serverTimestamp()
//               : null,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//         Fluttertoast.showToast(msg: "Task status updated to: $newStatus");
//         // TODO: #1 - Implement Push Notification for task update/completion
//       } catch (e) {
//         Fluttertoast.showToast(msg: "Error updating task status: $e");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//     final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           _currentCategoryFilter == 'All' 
//               ? "My Tasks" 
//               : "${_currentCategoryFilter} Tasks",
//         ),
//         actions: [
//           _buildFilterDropdown(),
//           // if (user != null)
//           //   Padding(
//           //     padding: EdgeInsets.only(right: 16.0),
//           //     child: CircleAvatar(
//           //       backgroundImage: user.photoURL != null
//           //           ? NetworkImage(user.photoURL!)
//           //           : null,
//           //       child: user.photoURL == null ? Icon(Icons.person) : null,
//           //     ),
//           //   ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.pushNamed(
//             context,
//             RoutesName.addTaskScreen,
//           );
//         },
//         label: Text("New Task"),
//         icon: Icon(Icons.add),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 user?.displayName ?? "Task User",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               accountEmail: Text(user?.email ?? "No Email"),
//               currentAccountPicture: CircleAvatar(
//                 backgroundImage: user?.photoURL != null
//                     ? NetworkImage(user!.photoURL!)
//                     : null,
//                 child: user?.photoURL == null
//                     ? Icon(Icons.person, color: Colors.white)
//                     : null,
//               ),
//               decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//             ),
//             ListTile(
//               leading: Icon(Icons.home),
//               title: Text("All Tasks"),
//               onTap: () {
//                 setState(() {
//                   _currentFilter = 'All';
//                   _currentCategoryFilter = 'All'; // Reset category filter
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.category),
//               title: Text("Categories"),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer first
//                 // >>> IMPLEMENTED: Navigate to the Category Filter Screen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CategoryFilterScreen(
//                       onCategorySelected: _handleCategorySelection,
//                       currentCategory: _currentCategoryFilter,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             Divider(),
//             // Theme Mode Toggle - #5
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 8.0,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     isDarkTheme ? Icons.dark_mode : Icons.light_mode,
//                     color: isDarkTheme ? Colors.yellow : Colors.grey[700],
//                   ),
//                   SizedBox(width: 32),
//                   Text(
//                     isDarkTheme ? "Dark Mode" : "Light Mode",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Spacer(),
//                   Switch(
//                     value: isDarkTheme,
//                     onChanged: (value) {
//                       MyApp.of(context).toggleTheme(value);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Divider(),
//             ListTile(
//               leading: Icon(Icons.logout, color: Colors.red),
//               title: Text("Logout", style: TextStyle(color: Colors.red)),
//               onTap: () => logout(context),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Section (Simplified)
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Text(
//                 "Hello, ${user?.displayName?.split(' ').first ?? "Task User"}!",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w900,
//                   color: Theme.of(context).textTheme.bodyLarge?.color,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             _buildStatusTags(), // Enhanced UI element
//             SizedBox(height: 10),

//             // Tasks List
//             Expanded(
//               child: _currentUser == null
//                   ? _buildLoginPrompt()
//                   : _buildTasksList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget to display and switch filters visually
//   Widget _buildStatusTags() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: _statusFilters.map((filter) {
//           final isSelected = _currentFilter == filter;
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4.0),
//             child: ChoiceChip(
//               label: Text(
//                 filter == 'All' ? 'All Tasks' : filter.toUpperCase(),
//                 style: TextStyle(
//                   color: isSelected
//                       ? Colors.white
//                       : Theme.of(context).textTheme.bodyLarge?.color,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               selected: isSelected,
//               selectedColor: Theme.of(context).primaryColor,
//               backgroundColor: Theme.of(context).cardColor,
//               onSelected: (selected) {
//                 if (selected) {
//                   setState(() {
//                     _currentFilter = filter;
//                   });
//                 }
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Dropdown for sorting (Enhanced feature - #7)
//   Widget _buildFilterDropdown() {
//     return DropdownButton<String>(
//       value: _currentSort,
//       icon: Icon(Icons.sort, color: Colors.white),
//       underline: SizedBox(),
//       onChanged: (String? newValue) {
//         if (newValue != null) {
//           setState(() {
//             _currentSort = newValue;
//           });
//         }
//       },
//       items: <Map<String, String>>[
//         {'value': 'createdAt', 'label': 'Latest'},
//         {'value': 'dueDate', 'label': 'Due Date'},
//         {'value': 'priority', 'label': 'Priority'},
//       ].map<DropdownMenuItem<String>>((Map<String, String> item) {
//         return DropdownMenuItem<String>(
//           value: item['value'],
//           child: Text(
//             "Sort by: ${item['label']}",
//             style: TextStyle(
//               color: Theme.of(context).textTheme.bodyLarge?.color,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildLoginPrompt() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.login, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'Please login to view your tasks',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasksList() {
//     Query _query = _userTasksCollection;

//     // 1. Apply Status Filter
//     if (_currentFilter != 'All') {
//       _query = _query.where('status', isEqualTo: _currentFilter);
//     }
    
//     // 2. Apply Category Filter
//     if (_currentCategoryFilter != 'All') {
//       _query = _query.where('category', isEqualTo: _currentCategoryFilter);
//     }

//     // 3. Apply Sorting
//     _query = _query.orderBy(_currentSort, descending: true);
    
//     // Note: For 'priority' sorting, if you want High, Medium, Low order, 
//     // you would need a numeric field or client-side sorting. 
//     // Firestore only sorts strings lexicographically ('high' comes before 'low').

//     return StreamBuilder<QuerySnapshot>(
//       stream: _query.snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error loading tasks: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               'No tasks found for status: $_currentFilter and category: $_currentCategoryFilter.',
//               style: TextStyle(color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             final doc = snapshot.data!.docs[index];
//             final data = doc.data() as Map<String, dynamic>;
//             final isCompleted = data['status'] == 'completed';
//             final priority = data['priority']?.toString() ?? 'low';
//             final priorityColor = _priorityColors[priority] ?? Colors.green;

//             return Card(
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               elevation: 4,
//               child: ListTile(
//                 // Task Status Checkbox - #3
//                 leading: Checkbox(
//                   value: isCompleted,
//                   onChanged: (value) => _toggleTaskStatus(doc, value),
//                   activeColor: Colors.green,
//                 ),
//                 // Priority Indicator - #4, #8
//                 title: Text(
//                   data['title'] ?? 'No Title',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     decoration: isCompleted ? TextDecoration.lineThrough : null,
//                   ),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['description'] ?? 'No description',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     SizedBox(height: 4),
//                     // Due Date, Time, and Priority - #4, #6
//                     Row(
//                       children: [
//                         Icon(Icons.access_time, size: 14, color: Colors.grey),
//                         SizedBox(width: 4),
//                         Text(
//                           data['dueDate'] != null
//                               ? 'Due: ${_formatTimestamp(data['dueDate'], showTime: data['dueTime'] != null)}'
//                               : 'No Due Date',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                         SizedBox(width: 8),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: priorityColor.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             priority.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               color: priorityColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 trailing: IconButton(
//                   onPressed: () => _showDeleteDialog(doc),
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   tooltip: 'Delete Task',
//                 ),
//                 onTap: () {
//                   // Navigate to Edit Screen
//                   Navigator.pushNamed(
//                     context,
//                     RoutesName.editTaskScreen,
//                     arguments: doc.id,
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildItemCount() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _userTasksCollection.snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return Text(
//             '...',
//             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           );
//         final count = snapshot.data!.docs.length;
//         return Text(
//           'Total: $count',
//           style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           overflow: TextOverflow.ellipsis,
//         );
//       },
//     );
//   }

//   // Show delete confirmation dialog
//   void _showDeleteDialog(DocumentSnapshot doc) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Delete Task"),
//           content: Text("Are you sure you want to delete this task?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteTask(doc);
//                 Navigator.pop(context);
//               },
//               child: Text("Delete", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String _formatTimestamp(Timestamp timestamp, {bool showTime = false}) {
//     final date = timestamp.toDate();
//     if (showTime) {
//       return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//     }
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
////////////////////////////
///
///
///
///
///
///
///
///
// Filename: home_screen.dart (UPDATED for Numeric Priority Sorting)

import 'package:firebcrudapp/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart'; // Import to access MyApp's state
import 'category_filter_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection("tasks"); // Renamed collection

  // Filter state
  String _currentFilter = 'All'; // Status filter (All, pending, in-progress, completed)
  String _currentCategoryFilter = 'All'; // Category filter (All, Personal, Work, etc.)
  String _currentSort = 'createdAt'; // Can be 'createdAt', 'dueDate', or 'priorityRank'

  // Available filters and sort options
  final List<String> _statusFilters = [
    'All',
    'pending',
    'in-progress',
    'completed',
  ];
  final Map<String, Color> _priorityColors = {
    'high': Colors.red,
    'medium': Colors.orange,
    'low': Colors.green,
  };

  CollectionReference get _userTasksCollection {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }
    // Use 'user_tasks' subcollection
    return _itemsCollection.doc(_currentUser!.uid).collection('user_tasks');
  }

  // >>> NEW: Function to handle category selection from the filter screen
  void _handleCategorySelection(String category) {
    setState(() {
      _currentCategoryFilter = category;
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Fluttertoast.showToast(msg: "Logged Out");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  _deleteTask(DocumentSnapshot doc) async {
    try {
      await _userTasksCollection.doc(doc.id).delete();
      Fluttertoast.showToast(msg: "Task deleted");
      // TODO: #1 - Implement Push Notification for task deletion
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting task: $e");
    }
  }

  _toggleTaskStatus(DocumentSnapshot doc, bool? isCompleted) async {
    if (doc.exists) {
      final newStatus = isCompleted == true ? 'completed' : 'pending';
      try {
        await _userTasksCollection.doc(doc.id).update({
          'status': newStatus,
          'completedAt': isCompleted == true
              ? FieldValue.serverTimestamp()
              : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Fluttertoast.showToast(msg: "Task status updated to: $newStatus");
        // TODO: #1 - Implement Push Notification for task update/completion
      } catch (e) {
        Fluttertoast.showToast(msg: "Error updating task status: $e");
      }
    }
  }
  // Show delete confirmation dialog
void _showDeleteDialog(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  final taskTitle = data['title'] ?? 'this task';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Task"),
        content: Text("Are you sure you want to delete '$taskTitle'? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Call the delete function
              _deleteTask(doc);
              Navigator.pop(context); // Close the dialog
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentCategoryFilter == 'All' 
              ? "My Tasks" 
              : "${_currentCategoryFilter} Tasks",
        ),
        actions: [
          _buildFilterDropdown(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            RoutesName.addTaskScreen,
          );
        },
        label: Text("New Task"),
        icon: Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? "Task User",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("All Tasks"),
              onTap: () {
                setState(() {
                  _currentFilter = 'All';
                  _currentCategoryFilter = 'All'; // Reset category filter
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Categories"),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                // >>> IMPLEMENTED: Navigate to the Category Filter Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryFilterScreen(
                      onCategorySelected: _handleCategorySelection,
                      currentCategory: _currentCategoryFilter,
                    ),
                  ),
                );
              },
            ),
            Divider(),
            // Theme Mode Toggle - #5
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkTheme ? Colors.yellow : Colors.grey[700],
                  ),
                  SizedBox(width: 32),
                  Text(
                    isDarkTheme ? "Dark Mode" : "Light Mode",
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Switch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      MyApp.of(context).toggleTheme(value);
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section (Simplified)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Hello, ${user?.displayName?.split(' ').first ?? "Task User"}!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildStatusTags(), // Enhanced UI element
            SizedBox(height: 10),

            // Tasks List
            Expanded(
              child: _currentUser == null
                  ? _buildLoginPrompt()
                  : _buildTasksList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display and switch filters visually
  Widget _buildStatusTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                filter == 'All' ? 'All Tasks' : filter.toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Dropdown for sorting (Enhanced feature - #7)
  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _currentSort,
      icon: Icon(Icons.sort, color: Colors.white),
      underline: SizedBox(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _currentSort = newValue;
          });
        }
      },
      items: <Map<String, String>>[
        {'value': 'createdAt', 'label': 'Latest'},
        {'value': 'dueDate', 'label': 'Due Date'},
        {'value': 'priorityRank', 'label': 'Priority'}, // <<< UPDATED: Use priorityRank for correct sorting
      ].map<DropdownMenuItem<String>>((Map<String, String> item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(
            "Sort by: ${item['label']}",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Please login to view your tasks',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    Query _query = _userTasksCollection;

    // 1. Apply Status Filter
    if (_currentFilter != 'All') {
      _query = _query.where('status', isEqualTo: _currentFilter);
    }

    // 2. Apply Category Filter
    if (_currentCategoryFilter != 'All') {
      _query = _query.where('category', isEqualTo: _currentCategoryFilter);
    }

    // 3. Apply Sorting
    // If sorting by priority, we use priorityRank DESC (3, 2, 1)
    _query = _query.orderBy(_currentSort, descending: true);
    
    // NOTE: If you filter by category/status AND sort by priorityRank,
    // you must create a new composite index in Firebase for that combination,
    // like you did before, but using 'priorityRank' as the sort field.

    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No tasks found for status: $_currentFilter and category: $_currentCategoryFilter.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isCompleted = data['status'] == 'completed';
            final priority = data['priority']?.toString() ?? 'low';
            final priorityColor = _priorityColors[priority] ?? Colors.green;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 4,
              child: ListTile(
                // Task Status Checkbox - #3
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: (value) => _toggleTaskStatus(doc, value),
                  activeColor: Colors.green,
                ),
                // Priority Indicator - #4, #8
                title: Text(
                  data['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['description'] ?? 'No description',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    // Due Date, Time, and Priority - #4, #6
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          data['dueDate'] != null
                              ? 'Due: ${_formatTimestamp(data['dueDate'], showTime: data['dueTime'] != null)}'
                              : 'No Due Date',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () => _showDeleteDialog(doc),
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Task',
                ),
                onTap: () {
                  // Navigate to Edit Screen
                  Navigator.pushNamed(
                    context,
                    RoutesName.editTaskScreen,
                    arguments: doc.id,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ... (Other helper functions)

  String _formatTimestamp(Timestamp timestamp, {bool showTime = false}) {
    final date = timestamp.toDate();
    if (showTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}