import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:capstone/widgets/local_html_viewer.dart';

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

      if (mounted) {
        setState(() {
          healthInfoList = tempList;
          filteredList = List.from(healthInfoList);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('목록 로드 실패: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: !_isSearching
            ? const Text('건강정보 목록')
            : TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
          style: TextStyle(color: cs.onSurface, fontSize: 16),
          onChanged: _performSearch,
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
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
                backgroundColor: cs.primary.withOpacity(0.1),
                child: Icon(
                  Icons.health_and_safety,
                  color: cs.primary,
                  size: 24,
                ),
              ),
              title: Text(
                item['name'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                '건강정보 문서',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: cs.onSurfaceVariant,
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
