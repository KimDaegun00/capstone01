import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher_string.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'BackChannel',
        onMessageReceived: (JavaScriptMessage msg) async {
          final message = msg.message;

          // 뒤로가기
          if (message == 'goBack') {
            if (mounted) Navigator.of(context).pop();
            return;
          }

          // JSON 형식 메시지 처리
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'openExternal') {
              final url = data['url'];

              // 외부 브라우저로 열 수 있는지 확인
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url, mode: LaunchMode.externalApplication);
              } else {
                // 외부 브라우저 없으면 WebView 내부에서 열기
                _controller.loadRequest(Uri.parse(url));
              }
            }
          } catch (e) {
            debugPrint('Invalid JS message: $message');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // WebView 내부에서 열 수 있는 URL 허용
            if (request.url.startsWith('http')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    // 로컬 HTML 파일 불러오기 (Flutter asset)
    await _controller.loadFlutterAsset('assets/kakao_map.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
