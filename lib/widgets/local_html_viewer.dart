import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocalHtmlViewer extends StatefulWidget {
  final String assetPath; // assets/htmls/파일명.html
  
  const LocalHtmlViewer({
    Key? key,
    required this.assetPath,
  }) : super(key: key);

  @override
  State<LocalHtmlViewer> createState() => _LocalHtmlViewerState();
}

class _LocalHtmlViewerState extends State<LocalHtmlViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // WebViewController 설정 - 최소한의 설정으로 시작
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      // assets에서 HTML 파일 로드
      final htmlString = await rootBundle.loadString(widget.assetPath);
      // HTML 내용 검증
      if (htmlString.isEmpty) {
        throw Exception('HTML 내용이 비어있습니다');
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // WebView에 HTML 로드 (baseUrl 제거하여 URI 인코딩 문제 방지)
      await _controller.loadHtmlString(htmlString);
    } catch (e) {
      setState(() {
        _errorMessage = 'HTML 로드 실패: $e';
        _isLoading = false;
      });
      print('HTML 로드 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건강정보'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('HTML을 불러오는 중...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHtmlFromAssets,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : WebViewWidget(controller: _controller),
    );
  }
}
