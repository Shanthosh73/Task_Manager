import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled12/fourth.dart';
import 'task.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List<Task> tasks = [];
  String _filterOption = 'Show recent tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? taskTitle = prefs.getString('task_title');
    String? taskDescription = prefs.getString('task_description');
    String? taskStartDateString = prefs.getString('task_start_date');
    String? taskEndDateString = prefs.getString('task_end_date');

    if (taskTitle != null &&
        taskDescription != null &&
        taskStartDateString != null &&
        taskEndDateString != null) {
      setState(() {
        DateTime startDate = DateTime.parse(taskStartDateString);
        DateTime endDate = DateTime.parse(taskEndDateString);
        tasks.add(Task(
          topic: 'Task Topic',
          title: taskTitle,
          description: taskDescription,
          dates: [startDate, endDate],
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi Jerome',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img_1.png',
                    scale: 2,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Schedule your Tasks',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage your task schedule easy and efficiently',
                    style: TextStyle(fontSize: 10.0, color: Colors.black),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: _filterOption,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FourthScreen(),
            ),
          );
          if (result != null) {
            _addTask(result);
          }
        },
        child: Icon(
          Icons.add_circle,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        backgroundColor: Color.fromRGBO(63, 56, 201, 1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    task.title,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${task.dates.first.day}/${task.dates.first.month}/${task.dates.first.year} - ${task.dates.last.day}/${task.dates.last.month}/${task.dates.last.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _showTaskOptions(context, task);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
                title: Text(
                  'Edit Task',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditTask(task);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  'Delete Task',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(task);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FourthScreen(
          task: task,
        ),
      ),
    );

    if (result != null) {
      _updateTask(task, result);
    }
  }

  void _addTask(Map<String, dynamic> result) {
    setState(() {
      tasks.add(Task(
        topic: 'Task Topic',
        title: result['title'],
        description: result['description'],
        dates: result['dates'].cast<DateTime>(),
      ));
    });
  }

  void _updateTask(Task task, Map<String, dynamic> result) {
    setState(() {
      task.title = result['title'];
      task.description = result['description'];
      task.dates = result['dates'].cast<DateTime>();
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.black,
                ),
                title: Text(
                  'Sort by Date',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  setState(() {
                    _filterOption = 'Sort by Date';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: Colors.black,
                ),
                title: Text(
                  'Completed Tasks',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  setState(() {
                    _filterOption = 'Completed Tasks';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.pending_outlined,
                  color: Colors.black,
                ),
                title: Text(
                  'Pending Tasks',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  setState(() {
                    _filterOption = 'Pending Tasks';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
