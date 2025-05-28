import 'package:flutter/material.dart';

class InfoInputMainScreen extends StatefulWidget {
  @override
  _InfoInputMainScreenState createState() => _InfoInputMainScreenState();
}

class _InfoInputMainScreenState extends State<InfoInputMainScreen> {
  bool showStageButtons = false;
  String selectedStage = '';

  final TextEditingController input1Controller = TextEditingController();
  final TextEditingController input2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showStageButtons = !showStageButtons;
                  selectedStage = '';
                  input1Controller.clear();
                  input2Controller.clear();
                });
              },
              child: Text('입력 단계 선택'),
            ),
            if (showStageButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['전', '중', '후'].map((stage) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedStage = stage;
                      });
                    },
                    child: Text(stage),
                  );
                }).toList(),
              ),
            if (selectedStage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('$selectedStage 단계 입력창', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              TextField(
                controller: input1Controller,
                decoration: InputDecoration(
                  labelText: '$selectedStage 입력 1',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: input2Controller,
                decoration: InputDecoration(
                  labelText: '$selectedStage 입력 2',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // 완료 시 이전 화면으로 이동
                Navigator.pop(context);
              },
              child: Text('완료'),
            ),
          ],
        ),
      ),
    );
  }
}
