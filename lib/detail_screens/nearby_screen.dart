import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NearbyScreen extends StatefulWidget {
  @override
  _NearbyScreenState createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  String _displayText = 'get post 테스트';

  // GET 요청 (jsonplaceholder 테스트용)
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _displayText = 'GET 결과:\n${data['title']}';
      });
    } else {
      setState(() {
        _displayText = 'GET 실패: ${response.statusCode}';
      });
    }
  }

  // POST 요청 (jsonplaceholder 테스트용)
  Future<void> _sendData() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': 'foo', 'body': 'bar', 'userId': 1}),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        _displayText = 'POST 성공:\nID: ${data['id']}';
      });
    } else {
      setState(() {
        _displayText = 'POST 실패: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주변 시설'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _displayText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _fetchData,
                child: Text('GET 요청 보내기'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendData,
                child: Text('POST 요청 보내기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
