import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:capstone/widgets/local_html_viewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강정보 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HealthInfoList(),
    );
  }
}

class HealthInfoList extends StatefulWidget {
  const HealthInfoList({super.key});

  @override
  State<HealthInfoList> createState() => _HealthInfoListState();
}

class _HealthInfoListState extends State<HealthInfoList> {
  List<Map<String, String>> healthInfoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthInfoList();
  }

  Future<void> _loadHealthInfoList() async {
    try {
      print('=== Assets HTML 파일 목록 로드 시작 ===');

      // assets/htmls 폴더의 HTML 파일 목록 가져오기
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // assets/htmls/ 경로의 파일들만 필터링
      final htmlFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/htmls/') && key.endsWith('.html'))
          .map((String key) => key.replaceFirst('assets/htmls/', ''))
          .toList();

      print('발견된 HTML 파일 수: ${htmlFiles.length}');
      for (int i = 0; i < htmlFiles.length; i++) {
        print('파일 ${i + 1}: ${htmlFiles[i]}');
      }

      setState(() {
        healthInfoList = htmlFiles.map((fileName) => {
          'name': fileName.replaceAll('.html', '')
        }).toList();
        _isLoading = false;
      });

      print('=== 파일 목록 로드 완료 ===');
    } catch (e) {
      print('=== 에러 발생 ===');
      print('에러 내용: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목록 로드 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건강정보 목록'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: healthInfoList.length,
        itemBuilder: (context, index) {
          final item = healthInfoList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              title: Text(
                item['name'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                '건강정보 문서',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalHtmlViewer(
                      assetPath: 'assets/htmls/${item['name']}.html',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}