import 'package:flutter/material.dart';

class NearbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주변 시설'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능
          },
        ),
      ),
      body: Center(
        child: Text('주변 시설 화면'),
      ),
    );
  }
}
