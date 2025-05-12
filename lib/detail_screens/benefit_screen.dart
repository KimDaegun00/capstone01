import 'package:flutter/material.dart';

class BenefitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('혜택 안내'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능
          },
        ),
      ),
      body: Center(
        child: Text('혜택 안내 화면'),
      ),
    );
  }
}
