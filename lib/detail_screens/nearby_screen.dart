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
          try {
            final data = jsonDecode(msg.message);
            if (data['type'] == 'openExternal') {
              final url = data['url'];
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url, mode: LaunchMode.externalApplication);
              }
            } else if (data['type'] == 'goBack') {
              Navigator.of(context).pop();
            }
          } catch (e) {
            print('Invalid message from JS: ${msg.message}');
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
