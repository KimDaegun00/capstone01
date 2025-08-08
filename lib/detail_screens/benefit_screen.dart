import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PolicyRecommendationPage extends StatefulWidget {
  @override
  _PolicyRecommendationPageState createState() => _PolicyRecommendationPageState();
}

class _PolicyRecommendationPageState extends State<PolicyRecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  final _userInputController = TextEditingController();
  final _topKController = TextEditingController(text: '5');
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _submitRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
      _successMessage = '';
      _results = [];
    });

    try {
      final topK = int.tryParse(_topKController.text) ?? 5;

      print('🔄 Edge Function 호출 시작...');
      print('📝 사용자 입력: ${_userInputController.text.trim()}');
      print('🔢 추천 개수: $topK');

      final response = await Supabase.instance.client.functions.invoke(
        'query-to-policies', // 실제 Edge Function 호출
        body: {
          'userInput': _userInputController.text.trim(),
          'topK': topK,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      print('📊 응답 데이터: $data');
      print('📊 응답 데이터 타입: ${data.runtimeType}');

      if (data != null && data['success'] == true) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(data['results'] ?? []);
          _successMessage = '저출산 완화 정책 추천이 완료되었습니다!';
        });

        print('📊 추천 결과: ${_results.length}개 정책');
        print('📊 결과 상세: $_results');

        // 결과 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PolicyResultPage(
              results: _results,
              userInput: _userInputController.text.trim(),
              count: data['count'] ?? 0,
            ),
          ),
        );
      } else {
        final errorMsg = data?['error'] ?? data?['message'] ?? '알 수 없는 오류가 발생했습니다.';
        print('❌ 응답 데이터 분석:');
        print('  - success: ${data?['success']}');
        print('  - error: ${data?['error']}');
        print('  - message: ${data?['message']}');
        print('  - results: ${data?['results']}');
        print('  - count: ${data?['count']}');

        setState(() {
          _errorMessage = errorMsg;
        });
        print('❌ Edge Function 오류: $errorMsg');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류: $e';
      });
      print('❌ 정책 추천 오류: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저출산 완화 정책 추천'),
        backgroundColor: Colors.pink[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 설명 텍스트
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.family_restroom, color: Colors.pink[600]),
                        SizedBox(width: 8),
                        Text(
                          '저출산 완화 정책 추천 시스템',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '임신, 출산, 육아와 관련된 고민을 자연어로 입력하세요.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '예시:\n• "아이 키우는데 비용이 많이 들어요"\n• "임신 중에 받을 수 있는 혜택이 궁금해요"\n• "육아 휴직을 받고 싶어요"\n• "출산 후 복직이 걱정돼요"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 사용자 입력 필드
              TextFormField(
                controller: _userInputController,
                decoration: InputDecoration(
                  labelText: '임신/출산/육아 관련 고민을 입력하세요',
                  hintText: '예: 아이 키우는데 비용이 많이 들어요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.edit, color: Colors.pink[600]),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  if (value.trim().length < 5) {
                    return '더 자세한 내용을 입력해주세요.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // 추천 개수 입력 필드
              TextFormField(
                controller: _topKController,
                decoration: InputDecoration(
                  labelText: '추천 정책 개수',
                  hintText: '5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.list, color: Colors.pink[600]),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '추천 개수를 입력해주세요.';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return '1 이상의 숫자를 입력해주세요.';
                  }
                  if (number > 20) {
                    return '20개 이하로 입력해주세요.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              // 제출 버튼
              _loading
                  ? Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[600]!),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '저출산 완화 정책을 분석하고 있습니다...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.pink[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '잠시만 기다려주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : ElevatedButton.icon(
                onPressed: _submitRecommendation,
                icon: Icon(Icons.search, size: 20),
                label: Text(
                  '정책 추천 받기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),

              SizedBox(height: 16),

              // 성공 메시지 표시
              if (_successMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 오류 메시지 표시
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오류가 발생했습니다',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PolicyResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String userInput;
  final int count;

  const PolicyResultPage({
    Key? key,
    required this.results,
    required this.userInput,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저출산 완화 정책 결과'),
        backgroundColor: Colors.pink[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 정보
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.family_restroom, color: Colors.pink[600]),
                      SizedBox(width: 8),
                      Text(
                        '저출산 완화 정책 검색 결과',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '입력: "$userInput"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '추천 정책: ${count}건',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.pink[700],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 결과 목록
            Expanded(
              child: results.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '추천할 저출산 완화 정책이 없습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '다른 키워드로 다시 시도해보세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final policy = results[index];
                  final similarity = (policy['유사도'] ?? 0) * 100;

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getSimilarityColor(similarity),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        policy['서비스명'] ?? '서비스명 없음',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: _getSimilarityColor(similarity),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '유사도: ${similarity.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: _getSimilarityColor(similarity),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
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

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 80) return Colors.green;
    if (similarity >= 60) return Colors.orange;
    if (similarity >= 40) return Colors.amber;
    return Colors.red;
  }
}