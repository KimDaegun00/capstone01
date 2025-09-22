import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

class CaptchaService {
  static Future<String?> requestToken(BuildContext context) async {
    final siteKey = EnvConfig.hcaptchaSiteKey;
    if (siteKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('hCaptcha 사이트 키가 설정되지 않았습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? resolvedToken;

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (WebResourceError error) {
                debugPrint('hCaptcha WebView 에러: ${error.description}');
              },
            ),
          )
          ..addJavaScriptChannel(
            'HCAPTCHA',
            onMessageReceived: (message) {
              try {
                final Map<String, dynamic> payload = jsonDecode(message.message);
                final String type = payload['type'] as String? ?? '';
                
                if (type == 'success') {
                  resolvedToken = payload['token'] as String?;
                  Navigator.of(dialogContext).pop(resolvedToken);
                } else if (type == 'error' || type == 'expired') {
                  Navigator.of(dialogContext).pop(null);
                }
              } catch (e) {
                Navigator.of(dialogContext).pop(null);
              }
            },
          )
          ..loadHtmlString(_buildHCaptchaHtml(siteKey));

        return AlertDialog(
          title: const Text('봇이 아님을 확인해주세요'),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.75,
            height: MediaQuery.of(dialogContext).size.height * 0.6,
            child: WebViewWidget(controller: controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('취소'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  static Future<bool> verifyTokenServerSide(String token) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'verify-hcaptcha',
        body: {
          'token': token,
        },
      );
      final data = response.data;
      
      // 서버 응답 데이터 출력
      debugPrint('hCaptcha 서버 검증 응답: $data');
      debugPrint('응답 타입: ${data.runtimeType}');
      
      if (data is Map) {
        debugPrint('응답 맵 키들: ${data.keys.toList()}');
        debugPrint('success 값: ${data['success']}');
        debugPrint('success 타입: ${data['success'].runtimeType}');
        
        if (data['success'] == true) {
          debugPrint('hCaptcha 서버 검증 성공');
          return true;
        } else {
          debugPrint('hCaptcha 서버 검증 실패');
          return false;
        }
      } else {
        debugPrint('예상치 못한 응답 형식: $data');
        return false;
      }
    } catch (e) {
      debugPrint('hCaptcha 서버 검증 중 에러 발생: $e');
      return false;
    }
  }

  static String _buildHCaptchaHtml(String siteKey) {
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script type="text/javascript">
      function onloadCallback() {
        try {
          hcaptcha.render('hcaptcha-container', {
            sitekey: '$siteKey',
            size: 'normal',
            theme: 'light',
            hl: 'ko',
            callback: function(token) {
              if (window.HCAPTCHA && window.HCAPTCHA.postMessage) {
                window.HCAPTCHA.postMessage(JSON.stringify({ type: 'success', token: token }));
              }
            },
            'error-callback': function(error) {
              if (window.HCAPTCHA && window.HCAPTCHA.postMessage) {
                window.HCAPTCHA.postMessage(JSON.stringify({ 
                  type: 'error', 
                  error: error ? error.toString() : 'unknown_error' 
                }));
              }
            },
            'expired-callback': function() {
              if (window.HCAPTCHA && window.HCAPTCHA.postMessage) {
                window.HCAPTCHA.postMessage(JSON.stringify({ type: 'expired' }));
              }
            }
          });
        } catch (e) {
          if (window.HCAPTCHA && window.HCAPTCHA.postMessage) {
            window.HCAPTCHA.postMessage(JSON.stringify({ 
              type: 'error', 
              error: 'render_failed: ' + e.toString() 
            }));
          }
        }
      }
    </script>
    <script src="https://hcaptcha.com/1/api.js?host=test.mydomain.com&onload=onloadCallback&render=explicit" async defer></script>
    <style>
      body { 
        margin: 0; 
        padding: 0; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        height: 100vh; 
        background-color: #f5f5f5;
        overflow: hidden;
      }
      #hcaptcha-container { 
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        transform: scale(0.75);
        transform-origin: center;
      }
      iframe, .h-captcha {
        max-width: 100% !important;
        max-height: 100% !important;
        transform: scale(0.85) !important;
        transform-origin: center !important;
      }
      /* hCaptcha 내부 요소들 크기 조정 */
      .h-captcha iframe,
      .h-captcha > div {
        width: 100% !important;
        height: auto !important;
        max-width: 280px !important;
      }
    </style>
  </head>
  <body>
    <div id="hcaptcha-container"></div>
  </body>
  <script>
    if (!window.HCAPTCHA) {
      window.HCAPTCHA = { postMessage: function(_){} };
    }
  </script>
  </html>
''';
  }
}


