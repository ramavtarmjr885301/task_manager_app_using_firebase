// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// // 1. IMPORT THE SERVICE
// import 'package:firebcrudapp/services/notification_service.dart'; // Make sure this path is correct

// class AddTaskScreen extends StatefulWidget {
//   const AddTaskScreen({super.key});

//   @override
//   State<AddTaskScreen> createState() => _AddTaskScreenState();
// }

// class _AddTaskScreenState extends State<AddTaskScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final User? _currentUser = FirebaseAuth.instance.currentUser;
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String _selectedPriority = 'medium';
//   String _selectedCategory = 'Personal';

//   final List<String> _priorities = ['low', 'medium', 'high'];
//   final List<String> _categories = [
//     'Personal',
//     'Work',
//     'Study',
//     'Health',
//     'Shopping',
//     'Other',
//   ];

//   final CollectionReference _tasksCollection = FirebaseFirestore.instance
//       .collection("tasks");

//   CollectionReference get _userTasksCollection {
//     if (_currentUser == null) {
//       throw Exception('User not logged in');
//     }
//     return _tasksCollection.doc(_currentUser!.uid).collection('user_tasks');
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   _addTask() async {
//     if (_formKey.currentState!.validate() && _currentUser != null) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         DateTime? dueDateTime;
//         if (_selectedDate != null) {
//           dueDateTime = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//           );
//           if (_selectedTime != null) {
//             dueDateTime = dueDateTime.add(
//               Duration(
//                 hours: _selectedTime!.hour,
//                 minutes: _selectedTime!.minute,
//               ),
//             );
//           }
//         }

//         final newTaskData = {
//           'title': _titleController.text,
//           'description': _descriptionController.text,
//           'dueDate': dueDateTime != null
//               ? Timestamp.fromDate(dueDateTime)
//               : null,
//           'priority': _selectedPriority,
//           'category': _selectedCategory,
//           'status': 'pending',
//           'userId': _currentUser!.uid,
//           'createdAt': FieldValue.serverTimestamp(),
//         };

//         // Perform the Firestore Add operation and get the DocumentReference
//         final DocumentReference doc = await _userTasksCollection.add(
//           newTaskData,
//         );

//         // 2. ALARM LOGIC INTEGRATION (for task creation)
//         if (dueDateTime != null && dueDateTime.isAfter(DateTime.now())) {
//           // Use the Firestore Document ID's hashcode as the Notification ID
//           final notificationId = doc.id.hashCode;

//           await NotificationService().scheduleNotification(
//             id: notificationId,
//             title: "TASK REMINDER: ${newTaskData['title']}",
//             body: "Your high priority task is due soon!",
//             scheduledTime: dueDateTime,
//             payload: doc.id, // Pass task ID in payload for future actions
//           );
//         }
//         // END ALARM LOGIC

//         _titleController.clear();
//         _descriptionController.clear();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Task added successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Future.delayed(
//           Duration(milliseconds: 1500),
//           () => Navigator.pop(context),
//         );
//       } catch (e) {
//         // ... (Error handling)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error adding task: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     } else if (_currentUser == null) {
//       // ... (Login prompt)
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please login first'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ... (rest of the file remains unchanged)
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Add New Task")),
//       body: _currentUser == null ? _buildLoginPrompt() : _buildAddTaskForm(),
//     );
//   }

//   Widget _buildLoginPrompt() {
//     // ... (unchanged login prompt)
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.login, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'Please login to add tasks',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddTaskForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20.0),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Task Details',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),

//             // Task Title - #4
//             TextFormField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: "Task Title",
//                 hintText: "e.g., Complete Project Report",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.title),
//               ),
//               validator: (value) => (value == null || value.isEmpty)
//                   ? 'Please enter a task title'
//                   : null,
//             ),
//             SizedBox(height: 16),

//             // Task Description - #4
//             TextFormField(
//               controller: _descriptionController,
//               maxLines: 3,
//               minLines: 1,
//               decoration: InputDecoration(
//                 labelText: "Description",
//                 hintText: "Details about the task...",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.description),
//               ),
//               // Description can be optional, no validator needed here
//             ),
//             SizedBox(height: 20),

//             Divider(),
//             SizedBox(height: 20),

//             // Due Date Picker - #4, #6
//             ListTile(
//               title: Text(
//                 _selectedDate == null
//                     ? 'Select Due Date'
//                     : 'Due Date: ${DateFormat('EEE, MMM d, y').format(_selectedDate!)}',
//               ),
//               leading: Icon(Icons.calendar_today),
//               trailing: Icon(Icons.edit),
//               onTap: () => _selectDate(context),
//             ),

//             // Due Time Picker - #6
//             ListTile(
//               title: Text(
//                 _selectedTime == null
//                     ? 'Select Due Time (Optional)'
//                     : 'Due Time: ${_selectedTime!.format(context)}',
//               ),
//               leading: Icon(Icons.schedule),
//               trailing: Icon(Icons.edit),
//               onTap: () => _selectTime(context),
//             ),
//             SizedBox(height: 20),

//             // Priority Dropdown - #4
//             InputDecorator(
//               decoration: InputDecoration(
//                 labelText: "Priority",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.priority_high),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 0,
//                 ),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedPriority,
//                   isDense: true,
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() => _selectedPriority = newValue);
//                     }
//                   },
//                   items: _priorities.map<DropdownMenuItem<String>>((
//                     String value,
//                   ) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value.toUpperCase()),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Category Dropdown - #2
//             InputDecorator(
//               decoration: InputDecoration(
//                 labelText: "Category",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.category),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 0,
//                 ),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedCategory,
//                   isDense: true,
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() => _selectedCategory = newValue);
//                     }
//                   },
//                   items: _categories.map<DropdownMenuItem<String>>((
//                     String value,
//                   ) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             SizedBox(height: 40),

//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: Icon(Icons.save),
//                 label: Text(
//                   _isLoading ? 'SAVING TASK...' : 'SAVE TASK',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: _isLoading ? null : _addTask,
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
///////////////////
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
// Filename: add_task_screen.dart (UPDATED for Numeric Priority Ranking)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// 1. IMPORT THE SERVICE
import 'package:firebcrudapp/services/notification_service.dart'; // Make sure this path is correct

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'medium';
  String _selectedCategory = 'Personal';

  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Shopping',
    'Other',
  ];

  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection("tasks");

  CollectionReference get _userTasksCollection {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }
    return _tasksCollection.doc(_currentUser!.uid).collection('user_tasks');
  }

  // >>> NEW: Helper function for numeric priority rank
  int _getPriorityRank(String priority) {
    switch (priority) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 1;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  _addTask() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        DateTime? dueDateTime;
        if (_selectedDate != null) {
          dueDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
          if (_selectedTime != null) {
            dueDateTime = dueDateTime.add(
              Duration(
                hours: _selectedTime!.hour,
                minutes: _selectedTime!.minute,
              ),
            );
          }
        }

        final newTaskData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dueDate': dueDateTime != null
              ? Timestamp.fromDate(dueDateTime)
              : null,
          'priority': _selectedPriority,
          'priorityRank': _getPriorityRank(_selectedPriority), // <<< NEW FIELD SAVED
          'category': _selectedCategory,
          'status': 'pending',
          'userId': _currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Perform the Firestore Add operation and get the DocumentReference
        final DocumentReference doc = await _userTasksCollection.add(
          newTaskData,
        );

        // 2. ALARM LOGIC INTEGRATION (for task creation)
        if (dueDateTime != null && dueDateTime.isAfter(DateTime.now())) {
          // Use the Firestore Document ID's hashcode as the Notification ID
          final notificationId = doc.id.hashCode;

          await NotificationService().scheduleNotification(
            id: notificationId,
            title: "TASK REMINDER: ${newTaskData['title']}",
            body: "Your high priority task is due soon!",
            scheduledTime: dueDateTime,
            payload: doc.id, // Pass task ID in payload for future actions
          );
        }
        // END ALARM LOGIC

        _titleController.clear();
        _descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(
          Duration(milliseconds: 1500),
          () => Navigator.pop(context),
        );
      } catch (e) {
        // ... (Error handling)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_currentUser == null) {
      // ... (Login prompt)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... (rest of the file remains unchanged)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Task")),
      body: _currentUser == null ? _buildLoginPrompt() : _buildAddTaskForm(),
    );
  }

  Widget _buildLoginPrompt() {
    // ... (unchanged login prompt)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Please login to add tasks',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Task Title - #4
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Task Title",
                hintText: "e.g., Complete Project Report",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please enter a task title'
                  : null,
            ),
            SizedBox(height: 16),

            // Task Description - #4
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Details about the task...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              // Description can be optional, no validator needed here
            ),
            SizedBox(height: 20),

            Divider(),
            SizedBox(height: 20),

            // Due Date Picker - #4, #6
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : 'Due Date: ${DateFormat('EEE, MMM d, y').format(_selectedDate!)}',
              ),
              leading: Icon(Icons.calendar_today),
              trailing: Icon(Icons.edit),
              onTap: () => _selectDate(context),
            ),

            // Due Time Picker - #6
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Select Due Time (Optional)'
                    : 'Due Time: ${_selectedTime!.format(context)}',
              ),
              leading: Icon(Icons.schedule),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 20),

            // Priority Dropdown - #4
            InputDecorator(
              decoration: InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isDense: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedPriority = newValue);
                    }
                  },
                  items: _priorities.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Category Dropdown - #2
            InputDecorator(
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isDense: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedCategory = newValue);
                    }
                  },
                  items: _categories.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(
                  _isLoading ? 'SAVING TASK...' : 'SAVE TASK',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _addTask,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}