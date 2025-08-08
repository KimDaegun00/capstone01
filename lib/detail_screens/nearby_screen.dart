import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({Key? key}) : super(key: key);

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    // assets 폴더의 HTML 파일 로드
    String fileHtmlContents =
    await rootBundle.loadString('assets/kakao_map.html');
    _controller.loadHtmlString(fileHtmlContents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("카카오맵")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
