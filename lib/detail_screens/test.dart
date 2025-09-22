import 'package:flutter/material.dart';
import 'package:capstone/services/auth_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        debugPrint("유저가 있음");
        final profile = await AuthService.getUserProfile(user.id);
        if(profile == null) {
          debugPrint("profile is null");
        }
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
      else{
        debugPrint("유저가 없음");
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 정보'),
        // 라이트/다크 테마에 맞게 자동 적용
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf5f7fa), Color(0xFFc3cfe2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 유저 정보 카드
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '👤 유저 정보',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (_userProfile != null)
                           Column(
                             children: [
                               _buildInfoRow('📧 이메일', user?.email ?? 'N/A'),
                               _buildInfoRow('👤 별명', _userProfile?['별명'] ?? '미설정'),
                               _buildInfoRow('🎂 생년월일', _formatDateFromString(_userProfile?['생년월일'])),
                               _buildInfoRow('🏠 주소지', _userProfile?['주소지'] ?? '미설정'),
                               _buildInfoRow('⚧ 성별', _userProfile?['성별'] ?? '미설정'),
                               _buildInfoRow('🤰 임신여부', _userProfile?['임신여부'] == true ? '예' : '아니오'),
                               _buildInfoRow('📅 임신주차', _userProfile?['임신주차'] != null ? '${_userProfile?['임신주차']}주차' : '미설정'),
                             ],
                           )
                        else
                          const Text(
                            '프로필 정보를 불러올 수 없습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 기능 테스트 카드
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showProfileUpdateDialog();
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('프로필 수정'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 하단 정보
                Center(
                  child: Text(
                    'Supabase Auth Test App v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFromString(dynamic dateValue) {
    if (dateValue == null) return '미설정';
    if (dateValue is String) {
      try {
        final date = DateTime.parse(dateValue);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (e) {
        return dateValue;
      }
    }
    if (dateValue is DateTime) {
      return '${dateValue.year}-${dateValue.month.toString().padLeft(2, '0')}-${dateValue.day.toString().padLeft(2, '0')}';
    }
    return '미설정';
  }

  void _showProfileUpdateDialog() {
    final nicknameController = TextEditingController(text: _userProfile?['별명'] ?? '');
    final addressController = TextEditingController(text: _userProfile?['주소지'] ?? '');
    final formKey = GlobalKey<FormState>(); // Form 위젯을 위한 GlobalKey 추가
    
    // 상태 관리를 위한 변수들
    String selectedGender = _userProfile?['성별'] ?? '비밀';
    bool isPregnant = _userProfile?['임신여부'] ?? false;
    TextEditingController pregnancyWeekController = TextEditingController(text: _userProfile?['임신주차']?.toString() ?? '');
    DateTime? selectedBirthday = _userProfile?['생년월일'] != null
        ? (_userProfile!['생년월일'] is String ? DateTime.tryParse(_userProfile!['생년월일']) : _userProfile!['생년월일'])
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('프로필 수정'),
              content: SingleChildScrollView(
                child: Form( // Form 위젯으로 감싸서 validator 사용 가능하게 함
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nicknameController,
                        decoration: const InputDecoration(
                          labelText: '별명',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 생년월일 캘린더 선택
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedBirthday ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedBirthday = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '생년월일',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedBirthday != null
                                ? DateFormat('yyyy-MM-dd').format(selectedBirthday!)
                                : '날짜를 선택하세요',
                            style: TextStyle(
                              color: selectedBirthday != null ? Colors.black : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: '주소지',
                          hintText: '경기도 오산시 양산동',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 성별 라디오 버튼
                      const Text(
                        '성별',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 남자
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: '남자',
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                    isPregnant = false;
                                    pregnancyWeekController.clear();
                                  });
                                },
                              ),
                              const Text('남자'),
                            ],
                          ),
                          // 여자
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: '여자',
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                              const Text('여자'),
                            ],
                          ),
                          // 비밀
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: '비밀',
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                    isPregnant = false;
                                    pregnancyWeekController.clear();
                                  });
                                },
                              ),
                              const Text('비밀'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 임신여부 라디오 버튼 (성별이 '여자'일 때만 활성화)
                      const Text(
                        '임신 여부',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('예'),
                              value: true,
                              groupValue: isPregnant,
                              onChanged: selectedGender == '여자'
                                  ? (value) {
                                    setState(() {
                                      isPregnant = value!;
                                    });
                                  }
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('아니오'),
                              value: false,
                              groupValue: isPregnant,
                              onChanged: selectedGender == '여자'
                                  ? (value) {
                                    setState(() {
                                      isPregnant = value!;
                                      pregnancyWeekController.clear(); // 임신 안했으면 주차 초기화
                                    });
                                  }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 임신주차 입력 필드 (임신여부가 '예'일 때만 활성화)
                      TextFormField(
                        controller: pregnancyWeekController,
                        keyboardType: TextInputType.number,
                        enabled: isPregnant,
                        decoration: InputDecoration(
                          labelText: '임신주차 (숫자만)',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isPregnant ? Colors.white : Colors.grey[200],
                        ),
                        // 임신주차 유효성 검사 추가
                        validator: (value) {
                          if (isPregnant && (value == null || value.isEmpty)) {
                            return '임신 주차를 입력해주세요.';
                          }
                          if (value != null && value.isNotEmpty) {
                            final week = int.tryParse(value);
                            if (week == null || week < 0 || week > 42) {
                              return '0에서 42 사이의 숫자를 입력해주세요.';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 유효성 검사 통과 시에만 저장 로직 실행
                    if (formKey.currentState!.validate()) {
                      try {
                        final user = AuthService.currentUser;
                        if (user != null) {
                          final updates = {
                            '별명': nicknameController.text.trim(),
                            '생년월일': selectedBirthday?.toIso8601String(),
                            '주소지': addressController.text.trim(),
                            '성별': selectedGender,
                            '임신여부': isPregnant,
                            '임신주차': int.tryParse(pregnancyWeekController.text.trim()),
                          };
                          
                          await AuthService.updateUserProfile(
                            userId: user.id,
                            updates: updates,
                          );
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('프로필이 업데이트되었습니다!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadUserProfile(); // 프로필 새로고침
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('프로필 업데이트 오류: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}