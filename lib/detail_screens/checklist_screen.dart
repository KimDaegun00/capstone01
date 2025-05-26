import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final ScrollController _scrollController = ScrollController();


  final int currentWeekIndex = 0; // 예: 2주차라면 index 1


  final List<Map<String, dynamic>> weeklyTasks = [
    {"week": "1주차", "tasks": ["A", "B"]},
    {"week": "2주차", "tasks": ["C", "D"]},
    {"week": "3주차", "tasks": ["E", "F"]},
    {"week": "4주차", "tasks": ["G", "H"]},
    {"week": "5주차", "tasks": ["A", "B"]},
    {"week": "6주차", "tasks": ["C", "D"]},
    {"week": "7주차", "tasks": ["E", "F"]},
    {"week": "8주차", "tasks": ["G", "H"]},
    {"week": "9주차", "tasks": ["A", "B"]},
    {"week": "10주차", "tasks": ["C", "D"]},
    {"week": "11주차", "tasks": ["E", "F"]},
    {"week": "12주차", "tasks": ["G", "H"]},
  ];


  @override
  void initState() {
    super.initState();
    // 위젯이 그려지고 나서 스크롤 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentWeek();
    });
  }

  void _scrollToCurrentWeek() {
    // 각 카드 높이를 150 정도로 가정하고 계산
    double cardHeight = 180.0; // 마진 포함 여유를 줌
    _scrollController.animateTo(
      currentWeekIndex * cardHeight,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('체크리스트'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: weeklyTasks.length,
        itemBuilder: (context, index) {
          final week = weeklyTasks[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week['week'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...week['tasks'].map<Widget>((task) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("• $task"),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
