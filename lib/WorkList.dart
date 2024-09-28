import 'package:flutter/material.dart';
import 'package:testpj/Calendar.dart';
import 'package:testpj/Setting.dart';
import 'package:testpj/TaskStatistics.dart';
import 'package:testpj/WorkDetail.dart';

class WorkList extends StatefulWidget {
  const WorkList({Key? key}) : super(key: key);

  @override
  _WorkListState createState() => _WorkListState();
}

class _WorkListState extends State<WorkList> {
  final List<Map<String, String>> _tasks = [];
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedHost;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _contentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTaskDialog() {
    _selectedHost = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm công việc mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateField(),
              _buildTimeField(),
              _buildTextField(_contentController, 'Nội dung công việc'),
              _buildTextField(_locationController, 'Địa điểm'),
              _buildHostDropdown(),
              _buildTextField(_noteController, 'Ghi chú', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: _addTaskIfValid,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Ngày tháng'),
            readOnly: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _timeController,
            decoration: const InputDecoration(labelText: 'Thời gian'),
            readOnly: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () => _selectTime(context),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
    );
  }

  Widget _buildHostDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedHost,
      decoration: const InputDecoration(labelText: 'Người chủ trì'),
      hint: Text('Chọn người chủ trì'),
      items: ['Thanh Ngân', 'Hữu Nghĩa'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedHost = newValue;
        });
      },
    );
  }

  void _addTaskIfValid() {
    if (_selectedHost != null) {
      _addTask();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn người chủ trì')),
      );
    }
  }

  void _addTask() {
    if (_contentController.text.isNotEmpty && _selectedHost != null) {
      setState(() {
        _tasks.add({
          'date': _dateController.text,
          'time': _timeController.text,
          'content': _contentController.text,
          'location': _locationController.text,
          'host': _selectedHost!,
          'note': _noteController.text,
          'status': 'Tạo mới',
          'reviewer': '',
        });
      });
      _clearControllers();
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _clearControllers() {
    _dateController.clear();
    _timeController.clear();
    _contentController.clear();
    _locationController.clear();
    _noteController.clear();
    _selectedHost = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: _getBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Danh sách công việc';
      case 1:
        return 'Lịch';
      case 2:
        return 'Cài đặt';
      default:
        return '';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildTaskList();
      case 1:
        return CalendarScreen(tasks: _tasks);
      case 2:
        return SettingsScreen();
      case 3:
        return TaskStatisticsScreen(tasks: _tasks);
      default:
        return Container();
    }
  }

  Widget _buildTaskList() {
    return ReorderableListView.builder(
      itemCount: _tasks.length,
      onReorder: _reorderTasks,
      itemBuilder: (context, index) {
        return _buildTaskCard(index);
      },
    );
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
  }

  Widget _buildTaskCard(int index) {
    return Card(
      key: Key('$index'),
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(_tasks[index]['status']),
          child: Text(
            _tasks[index]['content']?.substring(0, 1).toUpperCase() ?? '',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          _tasks[index]['content'] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày: ${_tasks[index]['date']} - ${_tasks[index]['time']}'),
            Text('Địa điểm: ${_tasks[index]['location']}'),
            Text('Chủ trì: ${_tasks[index]['host']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editTask(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(index),
            ),
          ],
        ),
        onTap: () => _navigateToTaskDetail(index),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return _selectedIndex == 0
        ? FloatingActionButton(
      onPressed: _showAddTaskDialog,
      child: Icon(Icons.add),
      backgroundColor: Colors.teal,
    )
        : null;
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Công việc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Lịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'Thống kê công việc',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      showUnselectedLabels: true,
      onTap: _onItemTapped,
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Tạo mới':
        return Colors.blue;
      case 'Đã cập nhật':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa công việc này?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Xóa"),
              onPressed: () {
                _deleteTask(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _editTask(int index) {
    _dateController.text = _tasks[index]['date'] ?? '';
    _timeController.text = _tasks[index]['time'] ?? '';
    _contentController.text = _tasks[index]['content'] ?? '';
    _locationController.text = _tasks[index]['location'] ?? '';
    _noteController.text = _tasks[index]['note'] ?? '';
    _selectedHost = _tasks[index]['host'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa công việc'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateField(),
              _buildTimeField(),
              _buildTextField(_contentController, 'Nội dung công việc'),
              _buildTextField(_locationController, 'Địa điểm'),
              _buildHostDropdown(),
              _buildTextField(_noteController, 'Ghi chú', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _updateTask(index),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _updateTask(int index) {
    setState(() {
      _tasks[index] = {
        'date': _dateController.text,
        'time': _timeController.text,
        'content': _contentController.text,
        'location': _locationController.text,
        'host': _selectedHost!,
        'note': _noteController.text,
        'status': 'Đã cập nhật',
        'reviewer': '',
      };
    });
    Navigator.pop(context);
    _clearControllers();
  }

  void _navigateToTaskDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: _tasks[index],
          taskList: _tasks,
          taskIndex: index,
          onTaskUpdated: (updatedTask) {
            setState(() {
              _tasks[index] = updatedTask;
            });
          },
        ),
      ),
    );
  }
}