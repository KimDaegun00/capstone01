import 'package:flutter/material.dart';

class JoinForm extends StatefulWidget {
  @override
  _JoinFormState createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 이름 입력
              TextFormField(
                decoration: InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              SizedBox(height: 16),

              // 이메일 입력
              TextFormField(
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요.';
                  }
                  if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                    return '올바른 이메일 주소를 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? '',
              ),
              SizedBox(height: 16),

              // 비밀번호 입력
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? '',
              ),
              SizedBox(height: 32),

              // 제출 버튼
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // 여기서 나중에 POST 요청으로 서버에 회원가입 데이터 보낼 수 있음
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원가입 정보 저장 완료\n이름: $name\n이메일: $email')),
                    );
                  }
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
