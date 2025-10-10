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

          // 단순 문자열 처리
          if (message == 'goBack') {
            if (mounted) Navigator.of(context).pop();
            return;
          }

          // JSON 형식 메시지 처리
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'openExternal') {
              final url = data['url'];
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url,
                    mode: LaunchMode.externalApplication);
              }
            } else if (data['type'] == 'goBack') {
              if (mounted) Navigator.of(context).pop();
            }
          } catch (e) {
            debugPrint('Invalid JS message: $message');
          }
        },
      );
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    String fileHtmlContents =
    await rootBundle.loadString('assets/kakao_map.html');
    _controller.loadHtmlString(fileHtmlContents);
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
