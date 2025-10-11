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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // 페이지 로드 완료 후 추가 스타일링 적용
            await _applyMobileOptimizations();
          },
        ),
      );
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

      // HTML + 모바일 최적화 스타일
      final fullHtml = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            /* 기본 설정 */
            html, body {
              margin: 0;
              padding: 0;
              font-family: 'Helvetica', 'Arial', sans-serif;
              font-size: 16px;
              line-height: 1.6;
              color: #333;
              background-color: #ffffff;
              overflow-x: hidden;
            }
            
            /* 컨테이너 패딩 */
            .container, #container {
              padding: 0 12px;
            }
            
            /* 이미지 반응형 */
            img {
              max-width: 100%;
              height: auto;
              display: block;
              margin: 10px auto;
            }
            
            /* 비디오 반응형 */
            video {
              max-width: 100%;
              height: auto;
              display: block;
              margin: 10px auto;
            }
            
            /* 표 스타일링 및 가로 스크롤 */
            .table-wrapper {
              overflow-x: auto;
              -webkit-overflow-scrolling: touch;
              margin: 15px 0;
              border: 1px solid #ddd;
              border-radius: 8px;
            }
            
            table {
              width: 100%;
              min-width: 600px; /* 최소 너비 보장 */
              border-collapse: collapse;
              font-size: 14px;
              background-color: white;
            }
            
            th, td {
              padding: 8px 12px;
              text-align: left;
              border: 1px solid #ddd;
              word-wrap: break-word;
              overflow-wrap: break-word;
            }
            
            th {
              background-color: #f8f9fa;
              font-weight: bold;
              position: sticky;
              top: 0;
              z-index: 10;
            }
            
            /* 표 캡션 */
            .neoTableCaption, .healthTableCell {
              font-size: 12px;
              color: #666;
              padding: 8px;
            }
            
            /* 표 제목 */
            .neoTableTitle {
              font-weight: bold;
              background-color: #e9ecef;
              text-align: center;
            }
            
            /* 텍스트 크기 조정 */
            h1, h2, h3, h4, h5, h6 {
              margin: 20px 0 10px 0;
              color: #2c3e50;
              line-height: 1.4;
            }
            
            h2 {
              font-size: 20px;
              border-bottom: 2px solid #3498db;
              padding-bottom: 8px;
            }
            
            h3 {
              font-size: 18px;
              color: #34495e;
            }
            
            /* 문단 스타일 */
            p {
              margin: 10px 0;
              text-align: justify;
            }
            
            /* 목록 스타일 */
            ul, ol {
              margin: 10px 0;
              padding-left: 20px;
            }
            
            li {
              margin: 5px 0;
              line-height: 1.5;
            }
            
            /* 강조 텍스트 */
            strong, b {
              color: #2c3e50;
            }
            
            /* 링크 스타일 */
            a {
              color: #3498db;
              text-decoration: none;
            }
            
            a:hover {
              text-decoration: underline;
            }
            
            /* 박스 스타일 (요약문 등) */
            div[style*="border:3px solid #ffa500"] {
              margin: 15px 0;
              border-radius: 8px;
              box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            /* 버튼 스타일 */
            button, .btn-blue {
              background-color: #3498db;
              color: white;
              border: none;
              padding: 10px 20px;
              border-radius: 5px;
              font-size: 14px;
              margin: 10px 0;
            }
            
            /* 폼 요소 */
            input, select, textarea {
              max-width: 100%;
              box-sizing: border-box;
            }
            
            /* 반응형 미디어 쿼리 */
            @media (max-width: 768px) {
              body {
                font-size: 14px;
                padding: 0 8px;
              }
              
              h2 {
                font-size: 18px;
              }
              
              h3 {
                font-size: 16px;
              }
              
              table {
                font-size: 12px;
              }
              
              th, td {
                padding: 6px 8px;
              }
            }
            
            @media (max-width: 480px) {
              body {
                font-size: 13px;
                padding: 0 6px;
              }
              
              table {
                font-size: 11px;
              }
              
              th, td {
                padding: 4px 6px;
              }
            }
          </style>
        </head>
        <body>
          <div class="container">
            $htmlContent
          </div>
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
      debugPrint('HTML 로드 오류: $e');
    }
  }

  /// 모바일 최적화 적용
  Future<void> _applyMobileOptimizations() async {
    try {
      await _controller.runJavaScript('''
        (function() {
          // 표 래핑 및 스타일링
          var tables = document.querySelectorAll('table');
          tables.forEach(function(table) {
            if (table.parentElement.classList.contains('table-wrapper')) {
              return;
            }
            
            var wrapper = document.createElement('div');
            wrapper.className = 'table-wrapper';
            wrapper.style.cssText = 'overflow-x: auto; -webkit-overflow-scrolling: touch; margin: 15px 0; border: 1px solid #ddd; border-radius: 8px;';
            
            table.parentNode.insertBefore(wrapper, table);
            wrapper.appendChild(table);
            
            table.style.cssText = 'min-width: 600px; width: 100%; border-collapse: collapse; font-size: 14px; background-color: white;';
            
            var cells = table.querySelectorAll('th, td');
            cells.forEach(function(cell) {
              cell.style.cssText = 'padding: 8px 12px; border: 1px solid #ddd; word-wrap: break-word; overflow-wrap: break-word;';
            });
            
            var headers = table.querySelectorAll('th');
            headers.forEach(function(header) {
              header.style.cssText += 'background-color: #f8f9fa; font-weight: bold;';
            });
          });
          
          // 이미지 최적화
          var images = document.querySelectorAll('img');
          images.forEach(function(img) {
            img.style.cssText = 'max-width: 100%; height: auto; display: block; margin: 10px auto;';
          });
          
          // 비디오 최적화
          var videos = document.querySelectorAll('video');
          videos.forEach(function(video) {
            video.style.cssText = 'max-width: 100%; height: auto; display: block; margin: 10px auto;';
          });
          
          // 반응형 텍스트 크기 조정
          var width = window.innerWidth;
          if (width <= 480) {
            document.body.style.fontSize = '13px';
            var smallCells = document.querySelectorAll('th, td');
            smallCells.forEach(function(cell) {
              cell.style.padding = '4px 6px';
            });
          } else if (width <= 768) {
            document.body.style.fontSize = '14px';
            var mobileCells = document.querySelectorAll('th, td');
            mobileCells.forEach(function(cell) {
              cell.style.padding = '6px 8px';
            });
          }
        })();
      ''');
    } catch (e) {
      debugPrint('모바일 최적화 적용 오류: $e');
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
