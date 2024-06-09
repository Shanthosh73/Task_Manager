import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task.dart';

extension DateTimeExtension on DateTime {
  bool isAfterOrEquals(DateTime other) {
    return this.isAfter(other) || this.isAtSameMomentAs(other);
  }

  bool isBeforeOrEquals(DateTime other) {
    return this.isBefore(other) || this.isAtSameMomentAs(other);
  }
}

class FourthScreen extends StatefulWidget {
  final Task? task;

  FourthScreen({this.task});

  @override
  _FourthScreenState createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _startDate = widget.task!.dates.first;
      _endDate = widget.task!.dates.last;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_startDate != null && _endDate != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_title', _titleController.text);
      await prefs.setString('task_description', _descriptionController.text);
      await prefs.setString('task_start_date', _startDate!.toIso8601String());
      await prefs.setString('task_end_date', _endDate!.toIso8601String());
    }
  }

  Future<void> _clearTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('task_title');
    await prefs.remove('task_description');
    await prefs.remove('task_start_date');
    await prefs.remove('task_end_date');
  }

  String _getRangeText() {
    if (_startDate != null && _endDate != null) {
      return 'Task starting at ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    }
    return 'Select a date range';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = selectedDay;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (selectedDay.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = selectedDay;
        } else {
          _endDate = selectedDay;
        }
      }
    });
  }

  void _onSavePressed() async {
    if (_startDate != null && _endDate != null) {
      await _saveTask();
      Navigator.pop(context, {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dates': [_startDate!, _endDate!],
      });
    }
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(isEditing ? 'Edit Task' : 'Create New Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                selectedDayPredicate: (day) {
                  if (_startDate != null && _endDate == null) {
                    return isSameDay(day, _startDate!);
                  } else if (_startDate != null && _endDate != null) {
                    return day.isAfterOrEquals(_startDate!) &&
                        day.isBeforeOrEquals(_endDate!);
                  }
                  return false;
                },
                onDaySelected: _onDaySelected,
              ),
              SizedBox(height: 20),
              Container(
                color: Color.fromRGBO(235, 235, 250, 1),
                width: double.infinity,
                height: 29,
                alignment: Alignment.centerLeft,
                child: Text(
                  _getRangeText(),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              if (isEditing)
                Center(
                  child: ElevatedButton(
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(60, 36),
                    ),
                    child: Text('Update'),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _onCancelPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onSavePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(60, 36),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
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
}
