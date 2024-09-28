import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpj/themeprovider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, String> task;
  final List<Map<String, String>> taskList;
  final int taskIndex;
  final Function(Map<String, String>) onTaskUpdated;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    required this.taskList,
    required this.taskIndex,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _status;
  late String _reviewer;
  late TextEditingController _contentController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  String? _selectedHost;

  final Map<String, String> _reviewers = {
    'Tạo mới': '',
    'Thực hiện': '',
    'Thành công': '',
    'Kết thúc': '',
  };

  final TextEditingController _reviewerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.task['status'] ?? 'Tạo mới';
    _reviewer = _reviewers[_status] ?? '';
    _contentController = TextEditingController(text: widget.task['content']);
    _dateController = TextEditingController(text: widget.task['date']);
    _timeController = TextEditingController(text: widget.task['time']);
    _locationController = TextEditingController(text: widget.task['location']);
    _noteController = TextEditingController(text: widget.task['note']);
    _selectedHost = widget.task['host'];
  }

  @override
  void dispose() {
    _contentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateStatus(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật trạng thái'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn muốn cập nhật trạng thái thành "$newStatus"?'),
            TextField(
              controller: _reviewerController,
              decoration: InputDecoration(labelText: 'Người kiểm duyệt'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _status = newStatus;
                _reviewers[_status] = _reviewerController.text;
                _reviewer = _reviewers[_status]!;
                widget.task['status'] = _status;
                widget.task['reviewer'] = _reviewer;
              });
              Navigator.pop(context);
            },
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  bool _isButtonEnabled(String buttonStatus) {
    switch (_status) {
      case 'Tạo mới':
        return buttonStatus == 'Thực hiện';
      case 'Thực hiện':
        return buttonStatus == 'Thành công';
      case 'Thành công':
        return buttonStatus == 'Kết thúc';
      case 'Kết thúc':
        return false;
      default:
        return false;
    }
  }

  Color _getButtonColor(String buttonStatus) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    if (_isButtonEnabled(buttonStatus)) {
      return isDarkMode ? Colors.tealAccent : Colors.green;
    } else {
      return isDarkMode ? Colors.grey[800]! : Colors.grey;
    }
  }

  void _saveTaskDetails() {
    final updatedTask = {
      'content': _contentController.text,
      'date': _dateController.text,
      'time': _timeController.text,
      'location': _locationController.text,
      'note': _noteController.text,
      'host': _selectedHost!,
      'status': _status,
      'reviewer': _reviewer,
    };

    widget.onTaskUpdated(updatedTask);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTaskDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_contentController, 'Nội dung công việc'),
            SizedBox(height: 16),
            _buildDateTimePicker(),
            SizedBox(height: 16),
            _buildTextField(_locationController, 'Địa điểm'),
            SizedBox(height: 16),
            _buildHostDropdown(),
            SizedBox(height: 16),
            _buildTextField(_noteController, 'Ghi chú', maxLines: 3),
            SizedBox(height: 24),
            _buildStatusSection(),
            SizedBox(height: 24),
            _buildReviewHistory(),
            SizedBox(height: 24),
            _buildStatusUpdateButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(_dateController, 'Ngày'),
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          onPressed: () => _selectDate(context),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildTextField(_timeController, 'Thời gian'),
        ),
        IconButton(
          icon: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
          onPressed: () => _selectTime(context),
        ),
      ],
    );
  }

  Widget _buildHostDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedHost,
      decoration: InputDecoration(labelText: 'Người chủ trì'),
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

  Widget _buildStatusAndReviewSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildStatusSection(),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildReviewHistory(),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trạng thái hiện tại', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('$_status', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHistory() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lịch sử kiểm duyệt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            for (var entry in _reviewers.entries)
              if (entry.value.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cập nhật trạng thái:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatusButton('Thực hiện'),
            _buildStatusButton('Thành công'),
            _buildStatusButton('Kết thúc'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusButton(String status) {
    return ElevatedButton(
      onPressed: _isButtonEnabled(status) ? () => _updateStatus(status) : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary, backgroundColor: _getButtonColor(status),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(status),
    );
  }
}