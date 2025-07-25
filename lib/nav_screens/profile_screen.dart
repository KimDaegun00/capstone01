import 'package:flutter/material.dart';
import 'package:capstone/nav_screens/SettingsScreen.dart';
import 'package:capstone/nav_screens/joinform.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('내 정보 클릭됨')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add),  // 회원가입 아이콘
            title: Text('회원가입'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JoinForm()),
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
