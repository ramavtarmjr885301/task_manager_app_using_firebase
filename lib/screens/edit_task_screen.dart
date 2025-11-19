import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebcrudapp/services/notification_service.dart'; // Make sure this path is correct

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Task properties
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'medium';
  String _selectedCategory = 'Personal';
  String _currentStatus = 'pending';

  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Shopping',
    'Other',
  ];
  final List<String> _statuses = ['pending', 'in-progress', 'completed'];

  // >>> UI Enhancement: Priority Colors Map <<<
  final Map<String, Color> _priorityColors = {
    'high': Colors.red,
    'medium': Colors.orange,
    'low': Colors.green,
  };

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Firestore References
  CollectionReference get _userTasksCollection {
    if (_currentUser == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance
        .collection("tasks")
        .doc(_currentUser!.uid)
        .collection('user_tasks');
  }

  // Helper function for numeric priority rank
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

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  // Fetch the task data and pre-fill controllers/state 
  Future<void> _loadTaskData() async {
    try {
      final docSnapshot = await _userTasksCollection.doc(widget.taskId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _currentStatus = data['status'] ?? 'pending';
        _selectedPriority = data['priority'] ?? 'medium'; 
        _selectedCategory = data['category'] ?? 'Personal';

        if (data['dueDate'] != null) {
          final DateTime dueDate = (data['dueDate'] as Timestamp).toDate();
          setState(() {
            _selectedDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
            if (dueDate.hour != 0 || dueDate.minute != 0) {
              _selectedTime = TimeOfDay.fromDateTime(dueDate);
            }
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error loading task: $e");
    }
  }

  // Date and Time pickers (unchanged)
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

  // Update logic (with Alarm Integration)
  _updateTask() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      setState(() => _isLoading = true);

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

        final updatedTaskData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dueDate': dueDateTime != null
              ? Timestamp.fromDate(dueDateTime)
              : null,
          'priority': _selectedPriority,
          'priorityRank': _getPriorityRank(_selectedPriority),
          'category': _selectedCategory,
          'status': _currentStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _userTasksCollection.doc(widget.taskId).update(updatedTaskData);

        // ALARM LOGIC INTEGRATION
        final notificationId = widget.taskId.hashCode;

        if (dueDateTime != null &&
            dueDateTime.isAfter(DateTime.now()) &&
            _currentStatus != 'completed') {
          // Schedule or re-schedule the alarm
          await NotificationService().scheduleNotification(
            id: notificationId,
            title: "TASK REMINDER: ${_titleController.text}",
            body:
                "Your task is due now! Priority: ${_selectedPriority.toUpperCase()}",
            scheduledTime: dueDateTime,
            payload: widget.taskId,
          );
        } else {
          // Cancel the alarm
          await NotificationService().cancelNotification(notificationId);
        }

        Fluttertoast.showToast(msg: "Task updated successfully");

        Future.delayed(
          const Duration(milliseconds: 500),
          () => Navigator.pop(context),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error updating task: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modify Task Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Task Title - #4
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter a task title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Task Description - #4
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const SizedBox(height: 20),

              // Status Dropdown
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentStatus,
                    isDense: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _currentStatus = newValue);
                      }
                    },
                    items: _statuses.map<DropdownMenuItem<String>>((
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
              const SizedBox(height: 16),

              // >>> UI Enhancement: Date/Time Pickers as Cards <<<
              
              // Due Date Picker - #4, #6
              Card(
                elevation: 1,
                child: ListTile(
                  title: const Text(
                    'Due Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _selectedDate == null 
                        ? 'No Deadline'
                        : DateFormat('EEE, MMM d, y').format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                      color: _selectedDate == null ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  leading: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _selectDate(context),
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 12),

              // Due Time Picker - #6
              Card(
                elevation: 1,
                child: ListTile(
                  title: const Text(
                    'Due Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _selectedTime == null 
                        ? 'Optional Time'
                        : _selectedTime!.format(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.bold,
                      color: _selectedTime == null ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _selectTime(context),
                  ),
                  onTap: () => _selectTime(context),
                ),
              ),
              const SizedBox(height: 20),
              
              // >>> UI Enhancement: Priority Dropdown with Colored Dot <<<
              InputDecorator(
                decoration: const InputDecoration(
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
                      final color = _priorityColors[value] ?? Colors.grey;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              value.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: color),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown - #2
              InputDecorator(
                decoration: const InputDecoration(
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
              const SizedBox(height: 40),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.update),
                  label: Text(
                    _isLoading ? 'UPDATING TASK...' : 'UPDATE TASK',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updateTask,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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