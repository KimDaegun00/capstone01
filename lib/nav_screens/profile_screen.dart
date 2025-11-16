import 'package:flutter/material.dart';
import 'package:capstone/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:capstone/main.dart'; // ⬅️ tr(), langNotifier 사용

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        debugPrint("유저가 있음");
        final profile = await AuthService.getUserProfileWithWeeks(user.id);
        if (profile == null) {
          debugPrint("profile is null");
        }
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      } else {
        debugPrint("유저가 없음");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('프로필 정보', 'Profile Info')),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
              Color(0xFF0f172a),
              Color(0xFF020617),
            ]
                : const [
              Color(0xFFf5f7fa),
              Color(0xFFc3cfe2),
            ],
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
                          Text(
                            tr('👤 유저 정보', '👤 User Info'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (_userProfile != null)
                            Column(
                              children: [
                                _buildInfoRow(
                                  context,
                                  tr('📧 이메일', '📧 Email'),
                                  user?.email ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('👤 별명', '👤 Nickname'),
                                  _userProfile?['별명'] ??
                                      tr('미설정', 'Not set'),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('🎂 생년월일', '🎂 Date of Birth'),
                                  _formatDateFromString(
                                      _userProfile?['생년월일']),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('🏠 주소지', '🏠 Address'),
                                  _userProfile?['주소지'] ??
                                      tr('미설정', 'Not set'),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('⚧ 성별', '⚧ Gender'),
                                  _userProfile?['성별'] ??
                                      tr('미설정', 'Not set'),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('🤰 임신여부', '🤰 Status'),
                                  _userProfile?['임신여부'] == true
                                      ? tr('예', 'Yes')
                                      : tr('아니오', 'No'),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('📅 임신시작일', '📅 Start Date'),
                                  _formatDateFromString(
                                      _userProfile?['임신시작일']),
                                ),
                                _buildInfoRow(
                                  context,
                                  tr('📅 임신주차', '📅 Week'),
                                  _userProfile?['임신주차'] != null
                                      ? '${_userProfile?['임신주차']}${tr('주차', ' week')}'
                                      : tr('미설정', 'Not set'),
                                ),
                              ],
                            )
                          else
                            Text(
                              tr('프로필 정보를 불러올 수 없습니다.',
                                  'Unable to load profile.'),
                              style: TextStyle(color: cs.error),
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
                              onPressed: () => _showProfileUpdateDialog(),
                              icon: const Icon(Icons.edit),
                              label: Text(tr('프로필 수정', 'Edit Profile')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
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

  Widget _buildInfoRow(
      BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFromString(dynamic dateValue) {
    if (dateValue == null) return tr('미설정', 'Not set');
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
    return tr('미설정', 'Not set');
  }

  void _showProfileUpdateDialog() {
    final nicknameController =
    TextEditingController(text: _userProfile?['별명'] ?? '');
    final addressController =
    TextEditingController(text: _userProfile?['주소지'] ?? '');

    final formKey = GlobalKey<FormState>();

    // 상태 관리를 위한 변수들
    // ⚠️ DB에는 항상 '여자' / '남자' 만 저장되도록 기본값을 한국어로 유지
    String selectedGender = _userProfile?['성별'] ?? '여자';
    bool isPregnant = _userProfile?['임신여부'] ?? false;
    DateTime? selectedPregnancyStartDate = _userProfile?['임신시작일'] != null
        ? (_userProfile!['임신시작일'] is String
        ? DateTime.tryParse(_userProfile!['임신시작일'])
        : _userProfile!['임신시작일'])
        : null;
    DateTime? selectedBirthday = _userProfile?['생년월일'] != null
        ? (_userProfile!['생년월일'] is String
        ? DateTime.tryParse(_userProfile!['생년월일'])
        : _userProfile!['생년월일'])
        : null;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tr('프로필 수정', 'Edit Profile')),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nicknameController,
                        decoration: InputDecoration(
                          labelText: tr('별명', 'Nickname'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 생년월일 캘린더 선택
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                            selectedBirthday ?? DateTime.now(),
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
                          decoration: InputDecoration(
                            labelText: tr('생년월일', 'Date of Birth'),
                            border: const OutlineInputBorder(),
                            suffixIcon:
                            const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedBirthday != null
                                ? DateFormat('yyyy-MM-dd')
                                .format(selectedBirthday!)
                                : tr('날짜를 선택하세요', 'Select a date'),
                            style: TextStyle(
                              color: selectedBirthday != null
                                  ? cs.onSurface
                                  : cs.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: tr('주소지', 'Address'),
                          hintText: tr('경기도 오산시 양산동',
                              'e.g., Suwon, Gyeonggi'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 성별 라디오 버튼
                      Text(
                        tr('성별', 'Gender'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(tr('여자', 'Female')),
                              // DB에 저장되는 값은 항상 '여자'
                              value: '여자',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(tr('남자', 'Male')),
                              // DB에 저장되는 값은 항상 '남자'
                              value: '남자',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                  isPregnant = false; // 성별 변경 시 임신 여부 초기화
                                  selectedPregnancyStartDate = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 임신여부 라디오 버튼 (성별이 '여자'일 때만 활성화)
                      Text(
                        tr('임신 여부', 'Pregnancy'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(tr('예', 'Yes')),
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
                              title: Text(tr('아니오', 'No')),
                              value: false,
                              groupValue: isPregnant,
                              onChanged: selectedGender == '여자'
                                  ? (value) {
                                setState(() {
                                  isPregnant = value!;
                                  selectedPregnancyStartDate =
                                  null; // 임신 안했으면 시작일 초기화
                                });
                              }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 임신 시작일 캘린더 선택 (임신여부가 '예'일 때만 활성화)
                      Text(
                        tr('임신 시작일', 'Pregnancy Start Date'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isPregnant
                            ? () async {
                          final pickedDate =
                          await showDatePicker(
                            context: context,
                            initialDate:
                            selectedPregnancyStartDate ??
                                DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedPregnancyStartDate =
                                  pickedDate;
                            });
                          }
                        }
                            : null,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            suffixIcon:
                            const Icon(Icons.calendar_today),
                            enabled: isPregnant,
                          ),
                          child: Text(
                            isPregnant
                                ? (selectedPregnancyStartDate != null
                                ? DateFormat('yyyy-MM-dd')
                                .format(
                                selectedPregnancyStartDate!)
                                : tr('날짜를 선택하세요',
                                'Select a date'))
                                : tr(
                                '임신 여부가 "예"일 때 선택 가능합니다',
                                'Selectable only if pregnancy is "Yes"'),
                            style: TextStyle(
                              color: isPregnant
                                  ? (selectedPregnancyStartDate !=
                                  null
                                  ? cs.onSurface
                                  : cs.onSurface
                                  .withOpacity(0.7))
                                  : cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('취소', 'Cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (isPregnant &&
                          selectedPregnancyStartDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('임신 시작일을 선택해주세요.',
                                  'Please select pregnancy start date.'),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        final user = AuthService.currentUser;
                        if (user != null) {
                          final updates = {
                            '별명':
                            nicknameController.text.trim(),
                            '생년월일': selectedBirthday
                                ?.toIso8601String(),
                            '주소지':
                            addressController.text.trim(),
                            // 여기서 selectedGender는 항상 '여자' 또는 '남자'
                            '성별': selectedGender,
                            '임신여부': isPregnant,
                            '임신시작일':
                            selectedPregnancyStartDate
                                ?.toIso8601String(),
                          };

                          await AuthService.updateUserProfile(
                            userId: user.id,
                            updates: updates,
                          );

                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr('프로필이 업데이트되었습니다!',
                                      'Profile updated!'),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadUserProfile(); // 프로필 새로고침
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          debugPrint("프로필 업데이트 오류: $e");
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  tr('프로필 업데이트 오류: $e',
                                      'Profile update error: $e')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(tr('저장', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
