import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstone/services/auth_service.dart';

class PolicyRecommendationPage extends StatefulWidget {
  const PolicyRecommendationPage({super.key});

  @override
  _PolicyRecommendationPageState createState() => _PolicyRecommendationPageState();
}

class _PolicyRecommendationPageState extends State<PolicyRecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  final _userInputController = TextEditingController();
  final _topKController = TextEditingController(text: '10');
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  String _errorMessage = '';
  String _successMessage = '';
  final List<String> _categories = const [
    '보건·의료',
    '보육·교육',
    '보호·돌봄',
    '생활안정',
    '임신·출산',
    '주거·자립',
  ];
  String? _selectedCategory;
  final Map<String, List<String>> _categoryKeywordHints = const {
    '보건·의료': ['예방/접종', '의료비/치료비', '시술비/약제비', '보험료', '검진/검사', '난임'],
    '보육·교육': ['장학금', '다자녀', '다문화', '교육비/양육비', '축하금/지원금', '유치원/어린이집', '급식'],
    '보호·돌봄': ['입양', '저소득', '장애인', '돌봄', '가사'],
    '생활안정': ['감면', '취약계층'],
    '임신·출산': ['건강관리', '산후조리', '지원금/용품', '검사', '난임', '축하금/장려금'],
    '주거·자립': ['대출/이자', '청년', '신혼부부', '보증금'],
  };
  List<String> _selectedKeywords = [];
  bool _helperOpen = false;
  String? _tempSelectedCategory;
  List<String> _tempSelectedKeywords = [];
  final _customKeywordsController = TextEditingController(); // 사용자 정의 키워드 컨트롤러

  // 프로필 정보 반영 관련 변수들
  bool _useProfileInfo = false;
  Map<String, dynamic>? _userProfile;
  bool _profileLoading = false;

  // 프로필 정보 가져오기
  Future<void> _loadUserProfile() async {
    if (_profileLoading) return;

    if (mounted) {
      setState(() {
        _profileLoading = true;
      });
    }

      try {
        final user = AuthService.currentUser;
        if (user != null) {
          debugPrint("유저가 있음: ${user.id}");
          final profile = await AuthService.getUserProfileWithWeeks(user.id);
          debugPrint("프로필 데이터: $profile");

          if(profile == null) {
            debugPrint("profile is null");
            if (mounted) {
              setState(() {
                _errorMessage = '프로필 정보를 찾을 수 없습니다.';
                _profileLoading = false;
              });
            }
            return;
          }

          if (mounted) {
            setState(() {
              _userProfile = profile;
              _profileLoading = false;
            });
          }

          // 프로필 정보를 사용자 입력에 반영
          _applyProfileToInput();
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = '로그인이 필요합니다.';
              _profileLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '프로필 정보를 가져오는데 실패했습니다: $e';
            _profileLoading = false;
          });
        }
        print('❌ 프로필 로딩 오류: $e');
        print('❌ 오류 타입: ${e.runtimeType}');
        print('❌ 스택 트레이스: ${e.toString()}');
      }
  }

  // 프로필 정보를 사용자 입력에 반영
  void _applyProfileToInput() {
    if (_userProfile == null) return;

    String profileContext = '';

    // 주소지 정보 추가
    if (_userProfile!['주소지'] != null && _userProfile!['주소지'].toString().isNotEmpty) {
      profileContext += '주소지: ${_userProfile!['주소지']}';
    }

    // 성별 정보 추가
    if (_userProfile!['성별'] != null && _userProfile!['성별'].toString().isNotEmpty) {
      if (profileContext.isNotEmpty) profileContext += ', ';
      profileContext += '성별: ${_userProfile!['성별']}';
    }

    // 임신여부 정보 추가
    if (_userProfile!['임신여부'] != null) {
      if (profileContext.isNotEmpty) profileContext += ', ';
      final isPregnant = _userProfile!['임신여부'];
      if (isPregnant is bool) {
        profileContext += '임신여부: ${isPregnant ? '임신중' : '임신안함'}';
      } else if (isPregnant is String) {
        profileContext += '임신여부: $isPregnant';
      } else {
        profileContext += '임신여부: ${isPregnant.toString()}';
      }
    }

    // 임신주차 정보 추가
    if (_userProfile!['임신주차'] != null && _userProfile!['임신주차'].toString().isNotEmpty) {
      if (profileContext.isNotEmpty) profileContext += ', ';
      profileContext += '임신주차: ${_userProfile!['임신주차']}주';
    }

    // 기존 사용자 입력에 프로필 정보 추가
    final currentInput = _userInputController.text.trim();
    if (currentInput.isNotEmpty) {
      _userInputController.text = '$currentInput\n\n[프로필 정보: $profileContext]';
    } else {
      _userInputController.text = '[프로필 정보: $profileContext]';
    }
  }

  // 프로필 정보를 사용자 입력에서 제거
  void _removeProfileFromInput() {
    final currentInput = _userInputController.text.trim();
    if (currentInput.contains('[프로필 정보:')) {
      // 프로필 정보 부분을 제거
      final parts = currentInput.split('\n\n[프로필 정보:');
      if (parts.length > 1) {
        _userInputController.text = parts[0].trim();
      } else {
        // 프로필 정보만 있는 경우 빈 문자열로 설정
        _userInputController.text = '';
      }
    }
  }

  Future<void> _submitRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = '';
        _successMessage = '';
        _results = [];
      });
    }

    try {
      final topK = int.tryParse(_topKController.text) ?? 10;

      // 사용자 정의 키워드와 추천 키워드를 합치는 로직
      final customKeywords = _customKeywordsController.text
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty)
          .toList();
      final allKeywords = [..._selectedKeywords, ...customKeywords];


      print('🔄 Edge Function 호출 시작...');
      print('📝 사용자 입력: ${_userInputController.text.trim()}');
      print('🔢 추천 개수: $topK');
      print('🏷️ 선택된 키워드: $allKeywords'); // 합쳐진 키워드 로그 추가

      final response = await Supabase.instance.client.functions.invoke(
        'query-to-policies', // 실제 Edge Function 호출
        body: {
          'userInput': _userInputController.text.trim(),
          'topK': topK,
          'category': _selectedCategory,
          'keywords': allKeywords, // 합쳐진 키워드 전달
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      print('📊 응답 데이터: $data');
      print('📊 응답 데이터 타입: ${data.runtimeType}');

      if (data != null && data['success'] == true) {
        if (mounted) {
          setState(() {
            _results = List<Map<String, dynamic>>.from(data['results'] ?? []);
            _successMessage = '저출산 완화 정책 추천이 완료되었습니다!';
          });
        }

        print('📊 추천 결과: ${_results.length}개 정책');
        print('📊 결과 상세: $_results');

        // 결과 페이지로 이동
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PolicyResultPage(
                results: _results,
                userInput: _userInputController.text.trim(),
                count: data['count'] ?? 0,
                selectedCategory: _selectedCategory,
              ),
            ),
          );
        }
      } else {
        final errorMsg = data?['error'] ?? data?['message'] ?? '알 수 없는 오류가 발생했습니다.';
        print('❌ 응답 데이터 분석:');
        print('  - success: ${data?['success']}');
        print('  - error: ${data?['error']}');
        print('  - message: ${data?['message']}');
        print('  - results: ${data?['results']}');
        print('  - count: ${data?['count']}');

        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
          });
        }
        print('❌ Edge Function 오류: $errorMsg');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '네트워크 오류: $e';
        });
      }
      print('❌ 정책 추천 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      appBar: AppBar(
        title: Text('정책 추천 검색'),
        backgroundColor: Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              // 설명 텍스트
              Container(
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
                        Icon(Icons.family_restroom, color: Colors.blue[800]!),
                        SizedBox(width: 8),
                        Text(
                          '저출산 완화 정책 추천 시스템',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800]!,
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
                      '예시:\n• "아이 키우는데 비용이 많이 들어요"\n• "임신 중에 받을 수 있는 혜택이 궁금해요"\n• "육아 휴직을 받고 싶어요"',
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

              // 프로필 정보 반영 선택
              Container(
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
                        Icon(Icons.person, color: Colors.blue[600]),
                        SizedBox(width: 8),
                        Text(
                          '프로필 정보 반영',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '내 프로필 정보(주소지, 성별, 임신여부, 임신주차)를 정책 추천에 반영하시겠습니까?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _useProfileInfo,
                          onChanged: (value) {
                            setState(() {
                              _useProfileInfo = value!;
                              if (_useProfileInfo) {
                                _loadUserProfile();
                              }
                            });
                          },
                          activeColor: Colors.blue[600],
                        ),
                        Text('프로필 정보 반영'),
                        SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: _useProfileInfo,
                          onChanged: (value) {
                            setState(() {
                              _useProfileInfo = value!;
                              // 프로필 정보 반영을 해제할 때 입력란에서 프로필 정보 제거
                              if (!_useProfileInfo) {
                                _removeProfileFromInput();
                              }
                            });
                          },
                          activeColor: Colors.blue[600],
                        ),
                        Text('반영하지 않음'),
                      ],
                    ),
                    if (_profileLoading) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '프로필 정보를 불러오는 중...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_userProfile != null && _useProfileInfo) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '프로필 정보가 입력란에 자동으로 추가되었습니다.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 사용자 입력 필드
              TextFormField(
                controller: _userInputController,
                decoration: InputDecoration(
                  labelText: '임신/출산/육아 관련 고민을 입력하세요',
                  hintText: '예: 아이 키우는데 비용이 많이 들어요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.edit, color: Colors.blue[600]!),
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

              // 도움받기 토글 및 패널
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _helperOpen = !_helperOpen;
                      // 토글 열릴 때 임시 상태 초기화
                      if (_helperOpen) {
                        _tempSelectedCategory = _selectedCategory;
                        _tempSelectedKeywords = List<String>.from(_selectedKeywords);
                      }
                    });
                  },
                  icon: Icon(_helperOpen ? Icons.expand_less : Icons.support_agent, color: Colors.black54),
                  label: Text('정책 추천 상세', style: TextStyle(color: Colors.black54)),
                ),
              ),

              if (_helperOpen) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('서비스 분야 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _tempSelectedCategory,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('전체(필터 없음)'),
                          ),
                          ..._categories.map((c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tempSelectedCategory = value;
                            // 카테고리 바뀌면 임시 키워드 초기화
                            _tempSelectedKeywords = [];
                          });
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category, color: Colors.blue[600]),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      SizedBox(height: 12),
                      Text('추천 키워드', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Builder(builder: (ctx) {
                        final hints = _categoryKeywordHints[_tempSelectedCategory] ?? const <String>[];
                        if (hints.isEmpty) {
                          return Text('선택된 서비스 분야의 키워드가 없습니다.');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hints.map((h) {
                            final selected = _tempSelectedKeywords.contains(h);
                            return FilterChip(
                              label: Text(h),
                              selected: selected,
                              selectedColor: Colors.blue[200],
                              checkmarkColor: Colors.white,
                              onSelected: (v) {
                                setState(() {
                                  if (v && !_tempSelectedKeywords.contains(h)) {
                                    _tempSelectedKeywords.add(h);
                                  } else if (!v) {
                                    _tempSelectedKeywords.remove(h);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      }),

                      SizedBox(height: 12),
                      // 사용자 정의 키워드 입력 필드 추가
                      Text('추가 키워드 입력 (선택 사항)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _customKeywordsController,
                        decoration: InputDecoration(
                          labelText: '키워드를 쉼표(,)로 구분하여 입력하세요',
                          hintText: '예: 주택, 자금, 육아휴직',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // 취소: 임시 상태 폐기, 패널 닫기
                              setState(() {
                                _helperOpen = false;
                                _tempSelectedCategory = _selectedCategory;
                                _tempSelectedKeywords = List<String>.from(_selectedKeywords);
                              });
                            },
                            child: Text('취소'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // 적용: 임시 상태를 실제 상태로 반영
                              setState(() {
                                _selectedCategory = _tempSelectedCategory;
                                _selectedKeywords = List<String>.from(_tempSelectedKeywords);
                                _helperOpen = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                            ),
                            child: Text('선택 완료'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 8),
              ],

              // 선택된 키워드 표시 (확정 상태)
              if (_selectedCategory != null || _selectedKeywords.isNotEmpty || _customKeywordsController.text.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedCategory != null)
                      Chip(
                        label: Text(_selectedCategory!),
                        backgroundColor: Colors.blue[100],
                      ),
                    ..._selectedKeywords.map((k) => Chip(
                      label: Text(k),
                      onDeleted: () {
                        setState(() {
                          _selectedKeywords.remove(k);
                        });
                      },
                    )),
                    // 사용자 정의 키워드도 칩으로 표시
                    ..._customKeywordsController.text
                        .split(',')
                        .map((k) => k.trim())
                        .where((k) => k.isNotEmpty)
                        .map((k) => Chip(
                      label: Text(k),
                      onDeleted: () {
                        setState(() {
                          // 사용자 정의 키워드 삭제 로직
                          final currentKeywords = _customKeywordsController.text.split(',').map((ck) => ck.trim()).toList();
                          currentKeywords.remove(k);
                          _customKeywordsController.text = currentKeywords.join(', ');
                        });
                      },
                    )),
                    ActionChip(
                      label: Text('초기화'),
                      avatar: Icon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() {
                          _selectedKeywords.clear();
                          _selectedCategory = null; // 서비스분야도 초기화
                          _customKeywordsController.clear();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],

              SizedBox(height: 16),

              // 추천 개수 입력 필드
              TextFormField(
                controller: _topKController,
                decoration: InputDecoration(
                  labelText: '추천 정책 개수',
                  hintText: '10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.list, color: Colors.black),
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

              // 제출 버튼 (로딩 중 비활성화)
              ElevatedButton.icon(
                onPressed: _loading ? null : _submitRecommendation,
                icon: Icon(Icons.search, size: 20),
                label: Text(
                  '정책 추천 받기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[600]!,
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
          ),

          // 상단 오버레이 로딩 카드
          if (_loading)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '저출산 완화 정책을 분석하고 있습니다...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '잠시만 기다려주세요.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userInputController.dispose();
    _topKController.dispose();
    _customKeywordsController.dispose(); // 컨트롤러 폐기
    super.dispose();
  }
}

class PolicyResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String userInput;
  final int count;
  final String? selectedCategory;

  const PolicyResultPage({
    super.key,
    required this.results,
    required this.userInput,
    required this.count,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저출산 완화 정책 결과'),
        backgroundColor: Colors.blue[600],
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.family_restroom, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text(
                        '저출산 완화 정책 검색 결과',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
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
                  if (selectedCategory != null && selectedCategory!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.filter_alt, size: 16, color: Colors.blue[700]),
                        SizedBox(width: 6),
                        Text(
                          '적용된 필터: $selectedCategory',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    '추천 정책: $count건',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
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