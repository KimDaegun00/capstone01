import 'package:flutter/material.dart';
import 'package:capstone/main.dart'; // tr() 사용하려면 import

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('피드백', 'Feedback')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 아주 단순한 텍스트 입력창
            TextField(
              decoration: InputDecoration(
                hintText: tr('여기에 피드백을 입력하세요', 'Type your feedback here'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            // 제출 버튼 (아직 로직 없음)
            ElevatedButton(
              onPressed: () {
                // TODO: 실제 제출 처리
                Navigator.pop(context);
              },
              child: Text(tr('제출', 'Submit')),
            ),
          ],
        ),
      ),
    );
  }
}
