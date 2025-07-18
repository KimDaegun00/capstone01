import 'package:flutter/material.dart';
import 'package:capstone/nav_screens/SettingsScreen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('내 정보'),
            onTap: () {
              // 추후 내 정보 상세 화면 연결 가능
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('내 정보 클릭됨')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
