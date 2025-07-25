import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoInputMainScreen extends StatefulWidget {
  @override
  _InfoInputMainScreenState createState() => _InfoInputMainScreenState();
}

class _InfoInputMainScreenState extends State<InfoInputMainScreen> {
  final TextEditingController dayController = TextEditingController();

  @override
  void dispose() {
    dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '며칠 되셨나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextField(
              controller: dayController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: '일 수 입력',
                border: OutlineInputBorder(),
                hintText: '숫자만 입력하세요',
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final dayStr = dayController.text.trim();
                  if (dayStr.isEmpty || int.tryParse(dayStr) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('올바른 숫자를 입력하세요')),
                    );
                    return;
                  }

                  final startDate = DateTime.now();
                  final dayCount = int.parse(dayStr);

                  Navigator.pop(context, {
                    'startDate': startDate,
                    'dayCount': dayCount,
                  });
                },
                child: Text('완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
