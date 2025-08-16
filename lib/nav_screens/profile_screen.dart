import 'package:flutter/material.dart';
import 'package:capstone/nav_screens/joinform.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 정보'),
        // 라이트/다크 테마에 맞게 자동 적용
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('내 정보'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('내 정보 클릭됨')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('회원가입'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JoinForm()),
              );
            },
          ),
        ],
      ),
    );
  }
}