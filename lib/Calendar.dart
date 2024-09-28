import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:testpj/WorkDetail.dart';

class CalendarScreen extends StatefulWidget {
  final List<Map<String, String>> tasks;

  CalendarScreen({required this.tasks});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, String>> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      List<String> dateParts = task['date']!.split('/');
      DateTime taskDate = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
      return isSameDay(taskDate, day);
    }).toList();
  }

  void _navigateToTaskDetail(Map<String, String> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          taskList: widget.tasks,
          taskIndex: widget.tasks.indexOf(task),
          onTaskUpdated: (updatedTask) {
            setState(() {
              int index = widget.tasks.indexOf(task);
              if (index != -1) {
                widget.tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getTasksForDay(day);
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text('Chọn một ngày để xem công việc'))
                : ListView(
              children: _getTasksForDay(_selectedDay!).map((task) {
                return ListTile(
                  title: Text(task['content'] ?? 'Không có nội dung'),
                  subtitle: Text('Thời gian: ${task['time']}, Địa điểm: ${task['location']}'),
                  onTap: () => _navigateToTaskDetail(task),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}