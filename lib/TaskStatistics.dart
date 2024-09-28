import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskStatisticsScreen extends StatelessWidget {
  final List<Map<String, String>> tasks;

  TaskStatisticsScreen({required this.tasks});


  int _getTaskCountByStatus(String status) {
    return tasks.where((task) => task['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {

    final int newTasks = _getTaskCountByStatus('Tạo mới');
    final int inProgressTasks = _getTaskCountByStatus('Thực hiện');
    final int successTasks = _getTaskCountByStatus('Thành công');
    final int finishedTasks = _getTaskCountByStatus('Kết thúc');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Thống kê công việc',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: newTasks.toDouble(),
                      title: 'Tạo mới ($newTasks)',
                      color: Colors.blue,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: inProgressTasks.toDouble(),
                      title: 'Thực hiện ($inProgressTasks)',
                      color: Colors.orange,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: successTasks.toDouble(),
                      title: 'Thành công ($successTasks)',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: finishedTasks.toDouble(),
                      title: 'Kết thúc ($finishedTasks)',
                      color: Colors.purple,
                      radius: 50,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend('Tạo mới', Colors.blue),
                _buildLegend('Thực hiện', Colors.orange),
                _buildLegend('Thành công', Colors.green),
                _buildLegend('Kết thúc', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(title),
      ],
    );
  }
}
