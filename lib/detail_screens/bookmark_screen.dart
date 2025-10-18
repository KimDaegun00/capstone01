import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstone/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, dynamic>> _bookmarkedPolicies = [];
  bool _loading = true;
  String _errorMessage = '';
  Map<String, bool> _bookmarkLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarkedPolicies();
  }

  // 즐겨찾기된 정책 목록 가져오기
  Future<void> _loadBookmarkedPolicies() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = '';
      });
    }

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _errorMessage = '로그인이 필요합니다.';
            _loading = false;
          });
        }
        return;
      }

      print('🔄 즐겨찾기된 정책 목록 로딩 시작...');
      print('📝 사용자: ${user.id}');

      // Edge Function을 사용하여 즐겨찾기된 정책 목록 가져오기
      final response = await Supabase.instance.client.functions.invoke(
        'get-bookmarked-policies',
        body: {
          'userId': user.id,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      print('📊 응답 데이터: $data');

      if (data != null && data['success'] == true) {
        final policies = List<Map<String, dynamic>>.from(data['policies'] ?? []);
        
        print('✅ 즐겨찾기된 정책 목록 로딩 완료: ${policies.length}개');

        if (mounted) {
          setState(() {
            _bookmarkedPolicies = policies;
            _loading = false;
          });
        }
      } else {
        final errorMsg = data?['error'] ?? data?['message'] ?? '알 수 없는 오류가 발생했습니다.';
        
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _loading = false;
          });
        }
        print('❌ 즐겨찾기 목록 로딩 오류: $errorMsg');
      }

    } catch (e) {
      print('❌ 즐겨찾기 목록 로딩 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '네트워크 오류: $e';
          _loading = false;
        });
      }
    }
  }

  // 즐겨찾기 제거 함수
  Future<void> _removeBookmark(String serviceId, String serviceName) async {
    if (_bookmarkLoadingStates[serviceId] == true) return;

    setState(() {
      _bookmarkLoadingStates[serviceId] = true;
    });

    try {
      print('🔄 즐겨찾기 제거 시작...');
      print('📝 서비스ID: $serviceId');
      print('📝 서비스명: $serviceName');

      final response = await Supabase.instance.client.functions.invoke(
        'unbookmark-policy',
        body: {
          'serviceId': serviceId,
          'serviceName': serviceName,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      print('📊 응답 데이터: $data');

      if (data != null && data['success'] == true) {
        // 목록에서 제거
        setState(() {
          _bookmarkedPolicies.removeWhere((policy) => policy['서비스ID'] == serviceId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('즐겨찾기에서 제거되었습니다!'),
            backgroundColor: Colors.orange[600],
            duration: Duration(seconds: 2),
          ),
        );

        print('✅ 즐겨찾기 제거 완료');
      } else {
        final errorMsg = data?['error'] ?? data?['message'] ?? '알 수 없는 오류가 발생했습니다.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $errorMsg'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );

        print('❌ 즐겨찾기 제거 오류: $errorMsg');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
      print('❌ 즐겨찾기 제거 네트워크 오류: $e');
    } finally {
      setState(() {
        _bookmarkLoadingStates[serviceId] = false;
      });
    }
  }

  // URL을 외부 브라우저에서 열기
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('✅ URL 열기 성공: $url');
    } catch (e) {
      print('❌ URL 열기 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL을 여는 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정책 즐겨찾기'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookmarkedPolicies,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '즐겨찾기된 정책을 불러오는 중...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        '오류가 발생했습니다',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadBookmarkedPolicies,
                        icon: Icon(Icons.refresh),
                        label: Text('다시 시도'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _bookmarkedPolicies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            '즐겨찾기된 정책이 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '정책 추천에서 관심 있는 정책을\n즐겨찾기에 추가해보세요.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 요약 정보
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bookmark, color: Colors.blue[600]),
                                    SizedBox(width: 8),
                                    Text(
                                      '즐겨찾기된 정책',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '총 ${_bookmarkedPolicies.length}개의 정책이 즐겨찾기에 추가되어 있습니다.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // 즐겨찾기 목록
                          Expanded(
                            child: ListView.builder(
                              itemCount: _bookmarkedPolicies.length,
                              itemBuilder: (context, index) {
                                final policy = _bookmarkedPolicies[index];
                                final serviceId = policy['서비스ID']?.toString() ?? '';
                                final serviceName = policy['서비스명'] ?? '서비스명 없음';
                                final isLoading = _bookmarkLoadingStates[serviceId] ?? false;

                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[600],
                                      child: Icon(
                                        Icons.bookmark,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      serviceName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '즐겨찾기된 정책',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                                              ),
                                            )
                                          : Icon(
                                              Icons.bookmark_remove,
                                              color: Colors.red[600],
                                              size: 24,
                                            ),
                                      onPressed: isLoading
                                          ? null
                                          : () => _removeBookmark(serviceId, serviceName),
                                      tooltip: '즐겨찾기에서 제거',
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (policy['서비스ID'] != null) ...[
                                              _buildInfoRow('서비스ID', policy['서비스ID']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['서비스목적요약'] != null) ...[
                                              _buildInfoRow('서비스목적요약', policy['서비스목적요약']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['서비스분야'] != null) ...[
                                              _buildInfoRow('서비스분야', policy['서비스분야']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['지원내용'] != null) ...[
                                              _buildInfoRow('지원내용', policy['지원내용']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['지원대상'] != null) ...[
                                              _buildInfoRow('지원대상', policy['지원대상']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['신청기한'] != null) ...[
                                              _buildInfoRow('신청기한', policy['신청기한']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['신청방법'] != null) ...[
                                              _buildInfoRow('신청방법', policy['신청방법']),
                                              SizedBox(height: 12),
                                            ],
                                            if (policy['상세조회URL'] != null) ...[
                                              _buildInfoRow('상세조회URL', policy['상세조회URL']),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    final isUrl = label == '상세조회URL';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getIconForLabel(label),
              size: 16,
              color: Colors.grey[600],
            ),
            SizedBox(width: 8),
            Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUrl ? Colors.blue[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isUrl ? Colors.blue[200]! : Colors.grey[200]!,
            ),
          ),
          child: isUrl && value != null && value.toString().isNotEmpty
              ? InkWell(
                  onTap: () => _launchUrl(value.toString()),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            height: 1.4,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                    ],
                  ),
                )
              : Text(
                  value?.toString() ?? '정보 없음',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case '서비스ID':
        return Icons.tag;
      case '서비스목적요약':
        return Icons.description;
      case '서비스분야':
        return Icons.category;
      case '지원내용':
        return Icons.info;
      case '지원대상':
        return Icons.people;
      case '신청기한':
        return Icons.schedule;
      case '신청방법':
        return Icons.how_to_reg;
      case '상세조회URL':
        return Icons.link;
      default:
        return Icons.info;
    }
  }
}
