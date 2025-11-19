import 'package:firebcrudapp/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'category_filter_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection("tasks");

  // Filter state
  String _currentFilter = 'All';
  String _currentCategoryFilter = 'All';
  String _currentSort = 'createdAt';

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

  // Permission tracking with SharedPreferences
  bool _isCheckingPermissions = false;
  static const String _batteryDialogShownKey = 'battery_dialog_shown_v2';

  CollectionReference get _userTasksCollection {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }
    return _itemsCollection.doc(_currentUser!.uid).collection('user_tasks');
  }

  // --- PERMISSION & FCM LOGIC START ---

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFCM();
    _checkSpecialPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed");
    }
  }

  Future<void> _checkSpecialPermissions() async {
    if (_isCheckingPermissions) return;
    _isCheckingPermissions = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownBatteryDialog =
          prefs.getBool(_batteryDialogShownKey) ?? false;

      PermissionStatus batteryStatus =
          await Permission.ignoreBatteryOptimizations.status;

      if (!hasShownBatteryDialog &&
          batteryStatus != PermissionStatus.granted &&
          mounted) {
        if (batteryStatus.isPermanentlyDenied) {
          print(
            "Battery optimization permission permanently denied. Directing user to App Settings.",
          );
        }

        await prefs.setBool(_batteryDialogShownKey, true);

        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("🔋 Optimize for Reliable Alarms"),
            content: const Text(
              "For the most reliable task reminders when the app is closed, enable 'Ignore Battery Optimization' permission. Please tap OK and enable it for this app.\n\nYou can always enable this later in Settings > Apps > This App > Battery > Unrestricted.",
            ),
            actions: [
              TextButton(
                child: const Text("Not Now"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Enable"),
                onPressed: () async {
                  Navigator.pop(context);

                  PermissionStatus result = await Permission
                      .ignoreBatteryOptimizations
                      .request();

                  if (result.isGranted) {
                    Fluttertoast.showToast(
                      msg: "Battery optimization enabled for reliable alarms!",
                      toastLength: Toast.LENGTH_LONG,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Permission required for reliable alarms.",
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                },
              ),
            ],
          ),
        );
      }

      final notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied && mounted) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Permission.notification.request();
          }
        });
      }
    } catch (e) {
      print("Error checking permissions: $e");
    } finally {
      _isCheckingPermissions = false;
    }
  }

  // Helper method to save the device token to a dedicated 'users' collection
  Future<void> _saveTokenToFirestore(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || token == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _initializeFCM() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
        print("FCM Token: $token");
      }

      messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('FCM Foreground Message: ${message.notification?.title}');
        Fluttertoast.showToast(
          msg: message.notification?.body ?? "New Task Notification",
          toastLength: Toast.LENGTH_LONG,
        );
      });
    } else {
      print('Notification permission denied: ${settings.authorizationStatus}');
    }
  }

  // --- PERMISSION & FCM LOGIC END ---

  // >>> UI ENHANCEMENTS START <<<

  Widget _buildTaskStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userTasksCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("No tasks yet."),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final totalTasks = snapshot.data!.docs.length;
        final completedTasks = snapshot.data!.docs
            .where((doc) => doc['status'] == 'completed')
            .length;
        final pendingTasks = totalTasks - completedTasks;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              _buildStatCard(
                context,
                Icons.task_alt,
                'Total Tasks',
                totalTasks,
                Colors.blue,
              ),

              const SizedBox(width: 6),
              _buildStatCard(
                context,
                Icons.check_circle,
                'Completed',
                completedTasks,
                Colors.green,
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                context,
                Icons.pending_actions,
                'Pending',
                pendingTasks,
                Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    int count,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 15),

                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  // >>> UI ENHANCEMENTS END <<<

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
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting task: $e");
    }
  }
/////////
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
          content: Text(
            "Are you sure you want to delete '$taskTitle'? This cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteTask(doc);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
        actions: [_buildFilterDropdown()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.addTaskScreen);
        },
        label: Text("New Task"),
        icon: Icon(Icons.add),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Account Header (Kept for visual appeal)
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? "Task User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),

            // 1. All Tasks (Home Link)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("All Tasks"),
              onTap: () {
                // Reset filters to All and close drawer
                setState(() {
                  _currentFilter = 'All';
                  _currentCategoryFilter = 'All';
                });
                Navigator.pop(context);
              },
            ),

            // 2. Categories (Filter Link)
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Categories"),
              onTap: () {
                Navigator.pop(context);
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

            const Divider(),

            // 3. Settings & Profile (New Centralized Link)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings & Profile"),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                // Navigate to the new screen
                Navigator.pushNamed(context, RoutesName.profileScreen);
              },
            ),

            // Optional: Keep Logout in the drawer as a secondary action
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section (REFINED)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10.0),
              child: Text(
                "Welcome back, ${user?.displayName?.split(' ').first ?? "Task User"}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),

            _buildTaskStats(), // <<< ENHANCED TASK STATISTICS

            _buildStatusTags(),
            const SizedBox(height: 10),

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

  // Dropdown for sorting
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
      items:
          <Map<String, String>>[
            {'value': 'createdAt', 'label': 'Latest'},
            {'value': 'dueDate', 'label': 'Due Date'},
            {'value': 'priorityRank', 'label': 'Priority'},
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
    bool isDescending = true;

    // FIX: Only override to ASCENDING (false) when sorting by Due Date,
    if (_currentSort == 'dueDate') {
      isDescending = false;
    } else {
      isDescending = true;
    }

    _query = _query.orderBy(_currentSort, descending: isDescending);

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
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 4,
              shape: RoundedRectangleBorder(
                // Highlight based on priority (thin colored border on the left)
                side: BorderSide(
                  color: priorityColor.withOpacity(isCompleted ? 0.2 : 0.8),
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                // Use InkWell for better visual tap feedback
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.editTaskScreen,
                    arguments: doc.id,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Completion Checkbox
                      Checkbox(
                        value: isCompleted,
                        onChanged: (value) => _toggleTaskStatus(doc, value),
                        activeColor: Colors.green,
                        shape: const CircleBorder(), // Use a circle checkbox
                      ),

                      const SizedBox(width: 8),

                      // 2. Task Content (Title, Description, Details)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Priority Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
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

                            // Description
                            if (data['description'] != null &&
                                data['description'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  data['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            // Due Date and Category Row (Overflow Fix Applied)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),

                                // FIX 1: Ensure Due Date Text is the flexible element and is constrained
                                Expanded(
                                  child: Text(
                                    data['dueDate'] != null
                                        ? 'Due: ${_formatTimestamp(data['dueDate'], showTime: data['dueTime'] != null)}'
                                        : 'No Due Date',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // FIX 2: Tightly pack the Category info
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.category,
                                  size: 14,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data['category'] ?? 'General',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.indigo,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 3. Delete Button
                      IconButton(
                        onPressed: () => _showDeleteDialog(doc),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        tooltip: 'Delete Task',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp, {bool showTime = false}) {
    final date = timestamp.toDate();
    if (showTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
