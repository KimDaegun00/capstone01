import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocalHtmlViewer extends StatefulWidget {
  final String assetPath; // assets/htmls/파일명.html

  const LocalHtmlViewer({
    super.key,
    required this.assetPath,
  });

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
    // WebViewController 설정
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadHtmlForAndroid();
  }

  /// CSS 없이 안드로이드 화면에 맞게 HTML 로드
  Future<void> _loadHtmlForAndroid() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // HTML 파일 읽기
      final htmlContent = await rootBundle.loadString(widget.assetPath);

      if (htmlContent.isEmpty) {
        throw Exception('HTML 내용이 비어있습니다.');
      }

      // HTML + 기본 스타일 (가로 스크롤 방지, 이미지/표 화면 맞춤)
      final fullHtml = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            /* 가로 스크롤 방지 */
            html, body {
              overflow-x: hidden;
              margin: 0;
              padding: 0 12px;
              font-family: sans-serif;
            }
            /* 이미지와 표 크기 화면에 맞춤 */
            img, table {
              max-width: 100%;
              height: auto;
            }
            /* 선택적 추가: 텍스트 크기 조정 */
            body {
              font-size: 16px;
              line-height: 1.5;
              color: #333;
            }
          </style>
        </head>
        <body>
          $htmlContent
        </body>
      </html>
      ''';

      // WebView에 로드
      await _controller.loadHtmlString(fullHtml);

      setState(() {
        _isLoading = false;
      });
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
              onPressed: _loadHtmlForAndroid,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      )
          : WebViewWidget(controller: _controller),
    );
  }
}
