import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinForm extends StatefulWidget {
  @override
  _JoinFormState createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final _formKey = GlobalKey<FormState>();

  // 입력값 상태 변수들
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  DateTime? birthDate;
  String address = '';
  bool isPregnant = false;
  int? pregnancyWeek;

  // 생일 선택 위젯
  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  // 폼 제출
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      String birthDateStr = birthDate?.toIso8601String() ?? '';

      final Map<String, dynamic> data = {
        "유저ID": email,
        "비밀번호": password,
        "이름": name,
        "생년월일": birthDateStr,
        "주소지": address,
        "임신여부": isPregnant ? 1 : 0,
        "임신주차": isPregnant ? pregnancyWeek ?? 0 : 0
      };

      try {
        final response = await http.post(
          Uri.parse("https://your-backend.com/api/register"), // ★ 실제 주소로 수정
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원가입 성공!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원가입 실패: ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("에러 발생: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 이름
              TextFormField(
                decoration: InputDecoration(labelText: '이름'),
                onSaved: (val) => name = val ?? '',
                validator: (val) =>
                val == null || val.isEmpty ? '이름을 입력하세요' : null,
              ),
              SizedBox(height: 16),

              // 이메일
              TextFormField(
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val ?? '',
                validator: (val) => val == null || !val.contains('@')
                    ? '올바른 이메일을 입력하세요'
                    : null,
              ),
              SizedBox(height: 16),

              // 비밀번호
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return '비밀번호를 입력하세요';
                  }
                  if (val.length < 6) {
                    return '6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 비밀번호 확인
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
                onChanged: (val) => confirmPassword = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return '비밀번호를 다시 입력하세요';
                  }
                  if (val != password) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 생년월일 선택
              Row(
                children: [
                  Text(birthDate == null
                      ? '생년월일을 선택하세요'
                      : '생년월일: ${birthDate!.toLocal().toString().split(' ')[0]}'),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectBirthDate(context),
                    child: Text('선택'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 주소지
              TextFormField(
                decoration: InputDecoration(labelText: '주소지'),
                onSaved: (val) => address = val ?? '',
              ),
              SizedBox(height: 16),

              // 임신 여부
              SwitchListTile(
                title: Text('임신 여부'),
                value: isPregnant,
                onChanged: (val) {
                  setState(() {
                    isPregnant = val;
                  });
                },
              ),

              // 임신 주차
              if (isPregnant)
                TextFormField(
                  decoration: InputDecoration(labelText: '임신 주차'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) =>
                  pregnancyWeek = int.tryParse(val ?? '') ?? 0,
                  validator: (val) {
                    if (isPregnant &&
                        (val == null || int.tryParse(val) == null)) {
                      return '임신 주차를 숫자로 입력하세요';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
