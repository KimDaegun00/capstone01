import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:capstone/widgets/local_html_viewer.dart';

void main() {
  runApp(const MyApp());
}

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
  List<Map<String, String>> filteredList = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHealthInfoList();
  }

  Future<void> _loadHealthInfoList() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final htmlFiles = manifestMap.keys
          .where((key) => key.startsWith('assets/htmls/') && key.endsWith('.html'))
          .toList();

      List<Map<String, String>> tempList = [];

      for (var path in htmlFiles) {
        final fileName = path.replaceFirst('assets/htmls/', '').replaceAll('.html', '');
        tempList.add({
          'name': fileName,
          'path': path, // 나중에 LocalHtmlViewer로 전달
        });
      }

      setState(() {
        healthInfoList = tempList;
        filteredList = List.from(healthInfoList);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목록 로드 실패: $e')),
      );
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      filteredList = List.from(healthInfoList);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      filteredList = healthInfoList.where((item) {
        final name = item['name']!.toLowerCase();
        return name.contains(_searchQuery); // 제목만 검색
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text('건강정보 목록')
            : TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black38),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: _performSearch,
        ),
        actions: [
          !_isSearching
              ? IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          )
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: _stopSearch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 2,
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      assetPath: item['path']!,
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
