import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

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

          if(message == 'map_is_ready') {
            _moveToCurrentLocation();
            return;
          }

          if(message == 'currentLocation'){
            _moveToCurrentLocation();
            return;
          }

          // JSON 형식 메시지 처리
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'openExternal') {
              final url = data['url'];

              try {
                final Uri uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                print('✅ 외부 URL 열기 성공: $url');
              } catch (e) {
                print('❌ 외부 URL 열기 실패: $e');
                // 외부 브라우저에서 열기 실패 시 WebView 내부에서 열기
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

  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 위치 서비스 활성화 및 권한 체크 (기존 로직 유지)
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // --- 지연 시간 단축을 위한 최적화 시작 ---
    
    // 2. 마지막으로 알려진 위치를 먼저 시도합니다.
    // 이 방법은 거의 즉시 위치를 반환하여 초기 지연을 제거합니다. (약간 덜 정확할 수 있음)
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      // 마지막 위치가 있다면, 즉시 반환하여 지도 이동을 실행합니다.
      return lastKnownPosition;
    }
    
    // 3. 마지막 위치가 없는 경우에만, 현재 위치를 새로 가져옵니다. (시간이 걸릴 수 있음)
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.medium // 정확도를 약간 낮춰 속도 개선 시도
    );

    return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }
  
  void _moveToCurrentLocation() async {
    try{
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lng = position.longitude;
      
      debugPrint("lat: ${lat}, lng: ${lng}");
      String script = 'setMapCenter($lat, $lng);';
      await _controller.runJavaScript(script);
    } catch (e) {
      debugPrint('Error moving to current location: $e');
    }
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
