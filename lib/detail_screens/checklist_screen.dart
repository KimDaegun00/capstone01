// lib/detail_screens/checklist_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone/services/auth_service.dart'; // ✅ 프로필(서버)에서 임신주차 로드
import 'package:supabase_flutter/supabase_flutter.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _sectionKeys;

  /// 완료 상태: weekIndex -> set of combined item index
  final Map<int, Set<int>> _doneByWeek = {};

  /// 사용자 추가 항목: weekIndex -> List<String>
  final Map<int, List<String>> _customByWeek = {};

  /// 서버에서 가져온 임신 주차
  int? _pregnancyWeek;

  /// 서버에서 가져온 항목 내용: weekIndex -> itemIndex -> content
  final Map<int, Map<int, String>> _itemContents = {};

  /// 화면에 실제로 그릴 주차 데이터(현재 주차 표시 포함)
  late List<WeekSectionData> _weeks = [];

  /// 로딩 상태 관리
  bool _isLoading = false;
  String? _errorMessage;

  int get _currentWeekIndex {
    final idx = _weeks.indexWhere((w) => w.isCurrent);
    debugPrint('_currentWeekIndex 계산: $idx (총 ${_weeks.length}개 섹션)');
    return idx;
  }

  // persistence keys (로컬 백업용)
  static const _kCustom = 'checklist_customByWeek_v1';
  static const _kDone = 'checklist_doneByWeek_v1';

  // ------------------ Supabase 연동 함수들 ------------------
  
  /// 체크리스트 시스템 항목 초기화 (사용자 추가 항목은 유지)
  Future<void> _initChecklistOnServer() async {
    try {
      setState(() { _isLoading = true; });
      final response = await Supabase.instance.client.functions.invoke(
        'checklist-crud',
        body: {
          'action': 'initSystem',
        },
      );
      final data = response.data;
      if (data != null && data['success'] == true) {
        // 로컬 상태도 초기화 (완료 상태만 초기화, 사용자 추가 항목은 유지)
        setState(() {
          _doneByWeek.clear();
          // _itemContents는 서버에서 다시 로드할 때 채워지므로 여기서는 초기화하지 않음
        });
        
        print('✅ 로컬 완료 상태 초기화 완료 (시스템 + 사용자 추가 항목 모두)');
        
        // 로컬 백업도 초기화
        await _clearLocalBackup();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('체크리스트가 초기화되었습니다.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // 서버에서 최신 데이터 로드
        await _loadChecklistFromServer();
      } else {
        final msg = data?['error'] ?? '초기화에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $msg'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네트워크 오류: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _confirmAndInitChecklist() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('체크리스트 초기화'),
          content: const Text('모든 항목의 완료 여부가 다시 설정됩니다.\n사용자 추가 항목은 유지됩니다. 진행할까요?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('초기화')),
          ],
        );
      },
    );
    if (ok == true) {
      await _initChecklistOnServer();
    }
  }
  
  /// 체크리스트 데이터 로드
  Future<void> _loadChecklistFromServer() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 체크리스트 데이터 로드 시작...');

      final response = await Supabase.instance.client.functions.invoke(
        'checklist-crud',
        body: {
          'action': 'load',
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      print('📊 응답 데이터: $data');

      if (data != null && data['success'] == true) {
        final checklistByWeek = data['checklistByWeek'] as Map<String, dynamic>? ?? {};
        final customByWeek = data['customByWeek'] as Map<String, dynamic>? ?? {};
        final doneByWeek = data['doneByWeek'] as Map<String, dynamic>? ?? {};

        setState(() {
          // 항목 내용 로드 (시스템 항목)
          _itemContents.clear();
          checklistByWeek.forEach((weekStr, items) {
            final weekIndex = int.tryParse(weekStr);
            if (weekIndex != null) {
              _itemContents[weekIndex] = {};
              for (final item in items as List) {
                final itemIndex = item['index'] as int;
                final content = item['content'] as String? ?? '';
                if (content.isEmpty) {
                  print('⚠️ 서버에서 빈 내용을 받았습니다: 주차 $weekIndex, 항목 $itemIndex');
                }
                _itemContents[weekIndex]![itemIndex] = content;
              }
            }
          });

          // 사용자 추가 항목 로드
          _customByWeek.clear();
          customByWeek.forEach((weekStr, items) {
            final weekIndex = int.tryParse(weekStr);
            if (weekIndex != null) {
              final itemList = (items as List).map((item) => item['title'] as String).toList();
              _customByWeek[weekIndex] = itemList;
              
              // 사용자 추가 항목의 내용도 _itemContents에 저장
              for (final item in items) {
                final itemIndex = item['index'] as int;
                final content = item['content'] as String? ?? '';
                if (content.isNotEmpty) {
                  _itemContents[weekIndex]![itemIndex] = content;
                }
              }
            }
          });

          // 완료 상태 로드
          _doneByWeek.clear();
          doneByWeek.forEach((weekStr, doneItems) {
            final weekIndex = int.tryParse(weekStr);
            if (weekIndex != null) {
              _doneByWeek[weekIndex] = Set<int>.from((doneItems as List).map((e) => e as int));
            }
          });
        });

        print('✅ 체크리스트 데이터 로드 완료');
        print('📊 로드된 항목 내용 개수: ${_itemContents.length}개 주차');
        print('📊 사용자 추가 항목 개수: ${_customByWeek.length}개 주차');
        _itemContents.forEach((weekIndex, items) {
          print('  - 주차 $weekIndex: ${items.length}개 항목');
          items.forEach((itemIndex, content) {
            if (content.isNotEmpty) {
              print('    * 항목 $itemIndex: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
            }
          });
        });
        _customByWeek.forEach((weekIndex, items) {
          print('  - 사용자 추가 주차 $weekIndex: ${items.length}개 항목');
        });
      } else {
        final errorMsg = data?['error'] ?? '체크리스트를 불러오는데 실패했습니다.';
        setState(() {
          _errorMessage = errorMsg;
        });
        print('❌ 체크리스트 로드 오류: $errorMsg');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류: $e';
      });
      print('❌ 체크리스트 로드 네트워크 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 체크리스트 항목 토글
  Future<void> _toggleItemOnServer(int weekIndex, int itemIndex, bool isCompleted) async {
    try {
      print('🔄 체크리스트 항목 토글: 주차 $weekIndex, 항목 $itemIndex, 완료 $isCompleted');

      final response = await Supabase.instance.client.functions.invoke(
        'checklist-crud',
        body: {
          'action': 'toggle',
          'weekIndex': weekIndex,
          'itemIndex': itemIndex,
          'isCompleted': isCompleted,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      if (data != null && data['success'] == true) {
        print('✅ 체크리스트 항목 토글 완료');
      } else {
        final errorMsg = data?['error'] ?? '항목 상태 업데이트에 실패했습니다.';
        print('❌ 체크리스트 토글 오류: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $errorMsg'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ 체크리스트 토글 네트워크 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 사용자 추가 항목 생성
  Future<void> _addCustomItemToServer(int weekIndex, String itemTitle, String itemContent) async {
    try {
      print('🔄 사용자 항목 추가: 주차 $weekIndex, 제목 $itemTitle, 내용: ${itemContent.isNotEmpty ? "있음" : "없음"}');

      final response = await Supabase.instance.client.functions.invoke(
        'checklist-crud',
        body: {
          'action': 'addCustom',
          'weekIndex': weekIndex,
          'itemTitle': itemTitle,
          'itemContent': itemContent,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      if (data != null && data['success'] == true) {
        print('✅ 사용자 항목 추가 완료');
        // 서버에서 다시 로드하여 최신 상태 반영
        await _loadChecklistFromServer();
      } else {
        final errorMsg = data?['error'] ?? '항목 추가에 실패했습니다.';
        print('❌ 사용자 항목 추가 오류: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $errorMsg'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ 사용자 항목 추가 네트워크 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 사용자 추가 항목 삭제
  Future<void> _deleteCustomItemFromServer(int weekIndex, int itemIndex) async {
    try {
      print('🔄 사용자 항목 삭제: 주차 $weekIndex, 항목 $itemIndex');

      final response = await Supabase.instance.client.functions.invoke(
        'checklist-crud',
        body: {
          'action': 'deleteCustom',
          'weekIndex': weekIndex,
          'itemIndex': itemIndex,
        },
      );

      print('✅ Edge Function 응답 받음: $response');

      final data = response.data;
      if (data != null && data['success'] == true) {
        print('✅ 사용자 항목 삭제 완료');
        // 서버에서 다시 로드하여 최신 상태 반영
        await _loadChecklistFromServer();
      } else {
        final errorMsg = data?['error'] ?? '항목 삭제에 실패했습니다.';
        print('❌ 사용자 항목 삭제 오류: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $errorMsg'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ 사용자 항목 삭제 네트워크 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();
    _weeks = []; // 빈 리스트로 시작
    // _weeksMaster의 길이를 기준으로 GlobalKey 생성 (고정된 12개 섹션)
    _sectionKeys = List.generate(_weeksMaster.length, (_) => GlobalKey());
    debugPrint(_sectionKeys.toString());
    for (int i = 0; i < _weeksMaster.length; i++) {
      _ensureWeek(i);
    }
    _loadPersisted(); // 로컬 백업 데이터 로드
    _loadPregnancyWeekAndApply(); // ✅ 서버에서 임신주차 로드 후 적용
    _loadChecklistFromServer(); // ✅ 서버에서 체크리스트 데이터 로드
  }

  void _ensureWeek(int weekIndex) {
    _doneByWeek.putIfAbsent(weekIndex, () => <int>{});
    _customByWeek.putIfAbsent(weekIndex, () => <String>[]);
  }

  // ------------------ 임신주차: 서버에서 로드 & 적용 ------------------
  Future<void> _loadPregnancyWeekAndApply() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final profile = await AuthService.getUserProfileWithWeeks(user.id);
      final v = profile?['임신주차'];

      int? week;
      if (v is int) {
        week = v;
      } else if (v is String) {
        week = int.tryParse(v);
      }

      if (!mounted) return;

      _pregnancyWeek = week;
      _applyPregnancyWeekToSections();
      
      // 위젯 트리 렌더링 완료 후 자동 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToCurrent();
        }
      });
    } catch (e) {
      debugPrint('임신주차 로드 실패: $e');
    }
  }

  void _applyPregnancyWeekToSections() {
    final idx = _indexForWeek(_pregnancyWeek);
    debugPrint('임신주차 적용: $_pregnancyWeek -> 인덱스 $idx');
    
    setState(() {
      // _weeks를 _weeksMaster 기준으로 초기화 (GlobalKey와 길이 일치)
      _weeks = List.generate(_weeksMaster.length, (i) {
        final base = _weeksMaster[i];
        final isCurrent = i == idx;
        if (isCurrent) {
          debugPrint('현재 주차로 설정: ${base.leftTitle} (인덱스 $i)');
        }
        return base.copyWith(isCurrent: isCurrent);
      });
    });
    
    // GlobalKey가 안전하게 연결될 수 있도록 한 프레임 대기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('위젯 트리 업데이트 완료, GlobalKey 준비됨 (총 ${_weeks.length}개 섹션)');
      }
    });
  }

  /// 겹치는 구간 우선순위 고려:
  /// 1~3, 4~6, 7~9, 10~13, 14~18, 19~22, 23~26, [27~29 우선], 24~28, 30~33, 34~36, 37~40
  int _indexForWeek(int? w) {
    if (w == null) return -1;
    if (w >= 1 && w <= 3) return 0;
    if (w >= 4 && w <= 6) return 1;
    if (w >= 7 && w <= 9) return 2;
    if (w >= 10 && w <= 13) return 3;
    if (w >= 14 && w <= 18) return 4;
    if (w >= 19 && w <= 22) return 5;
    if (w >= 23 && w <= 26) return 6;
    if (w >= 27 && w <= 29) return 8; // 27~29 우선
    if (w >= 24 && w <= 28) return 7;
    if (w >= 30 && w <= 33) return 9;
    if (w >= 34 && w <= 36) return 10;
    if (w >= 37 && w <= 40) return 11;
    return -1;
  }
  // --------------------------------------------------

  // ------------------ Persistence ------------------
  Future<void> _loadPersisted() async {
    final sp = await SharedPreferences.getInstance();

    final customRaw = sp.getString(_kCustom);
    if (customRaw != null) {
      final Map<String, dynamic> decoded = json.decode(customRaw);
      decoded.forEach((k, v) {
        final idx = int.tryParse(k);
        if (idx != null && idx >= 0 && idx < _weeks.length) {
          _customByWeek[idx] = List<String>.from(v as List);
        }
      });
    }

    final doneRaw = sp.getString(_kDone);
    if (doneRaw != null) {
      final Map<String, dynamic> decoded = json.decode(doneRaw);
      decoded.forEach((k, v) {
        final idx = int.tryParse(k);
        if (idx != null && idx >= 0 && idx < _weeks.length) {
          _doneByWeek[idx] = (v as List).map((e) => e as int).toSet();
        }
      });
    }

    if (mounted) setState(() {});
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();

    final customMap = <String, List<String>>{};
    _customByWeek.forEach((k, v) => customMap['$k'] = v);

    final doneMap = <String, List<int>>{};
    _doneByWeek.forEach((k, v) => doneMap['$k'] = v.toList());

    await sp.setString(_kCustom, json.encode(customMap));
    await sp.setString(_kDone, json.encode(doneMap));
  }

  /// 로컬 백업 초기화 (완료 상태만 초기화, 사용자 추가 항목은 유지)
  Future<void> _clearLocalBackup() async {
    final sp = await SharedPreferences.getInstance();
    
    // 완료 상태만 초기화
    await sp.remove(_kDone);
    
    // 사용자 추가 항목은 유지 (삭제하지 않음)
    print('✅ 로컬 백업 초기화 완료 (완료 상태만 초기화, 사용자 추가 항목 유지)');
  }
  // --------------------------------------------------

  List<String> _combinedItems(int weekIndex) {
    _ensureWeek(weekIndex);
    final custom = _customByWeek[weekIndex]!;
    return [..._weeks[weekIndex].items, ...custom];
  }

  void _toggleDone(int weekIndex, int combinedIndex) {
    _ensureWeek(weekIndex);
    final set = _doneByWeek[weekIndex]!;
    final isCurrentlyDone = set.contains(combinedIndex);
    final newState = !isCurrentlyDone;
    
    // 로컬 상태 먼저 업데이트 (즉시 UI 반영)
    if (newState) {
      set.add(combinedIndex);
    } else {
      set.remove(combinedIndex);
    }
    setState(() {});
    
    // 서버에 상태 동기화
    _toggleItemOnServer(weekIndex, combinedIndex, newState);
    
    // 로컬 백업 저장
    _persist();
  }

  int _doneCount(int weekIndex) {
    _ensureWeek(weekIndex);
    return _doneByWeek[weekIndex]!.length;
  }

  /// 항목 내용 가져오기 (서버 데이터 우선, 없으면 기본 메시지)
  String _getItemContent(int weekIndex, int itemIndex, String title) {
    // 서버에서 가져온 내용이 있으면 사용
    final serverContent = _itemContents[weekIndex]?[itemIndex];
    if (serverContent != null && serverContent.isNotEmpty) {
      print('✅ 항목 내용 찾음: 주차 $weekIndex, 항목 $itemIndex, 제목: $title');
      return serverContent;
    }
    
    // 서버 내용이 없으면 기본 메시지 표시
    print('⚠️ 서버에서 항목 내용을 가져오지 못했습니다: 주차 $weekIndex, 항목 $itemIndex, 제목: $title');
    print('   _itemContents 상태: ${_itemContents[weekIndex]?.keys.toList()}');
    
    // 사용자에게는 기본 메시지 표시
    return '이 항목에 대한 상세 정보가 없습니다.\n필요 시 담당 의료진과 상담을 권장드려요.';
  }

  Future<void> _addCustomItem(int weekIndex) async {
    _ensureWeek(weekIndex);
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이 주차에 항목 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // 제목 입력
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '항목 제목',
                  hintText: '예) 정밀 초음파 검사 / 간기능 검사',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              
              // 내용 입력
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '항목 내용 (선택사항)',
                  hintText: '이 항목에 대한 상세 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              
              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isNotEmpty) {
                          Navigator.pop(ctx, {
                            'title': title,
                            'content': contentController.text.trim(),
                          });
                        }
                      },
                      child: const Text('추가'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    
    if (result != null && result['title']!.isNotEmpty) {
      // 서버에 항목 추가 (제목과 내용 모두)
      await _addCustomItemToServer(weekIndex, result['title']!, result['content']!);
    }
  }

  Future<void> _deleteCustomItem(int weekIndex, int combinedIndex) async {
    _ensureWeek(weekIndex);
    final systemLen = _weeks[weekIndex].items.length;
    final localIndex = combinedIndex - systemLen; // 사용자 리스트 내 인덱스
    
    if (localIndex >= 0 && localIndex < _customByWeek[weekIndex]!.length) {
      final itemTitle = _customByWeek[weekIndex]![localIndex];
      
      // 삭제 확인 다이얼로그 표시
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('항목 삭제'),
            content: Text('"$itemTitle" 항목을 삭제하시겠습니까?\n삭제된 항목은 복구할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('삭제'),
              ),
            ],
          );
        },
      );
      
      if (confirmed == true) {
        // 서버에서 항목 삭제
        await _deleteCustomItemFromServer(weekIndex, combinedIndex);
      }
    }
  }

  void _scrollToCurrent() {
    final idx = _currentWeekIndex;
    debugPrint('현재 주차 인덱스: $idx (임신주차: $_pregnancyWeek)');
    
    if (idx < 0) {
      debugPrint('현재 주차 인덱스를 찾을 수 없음');
      return;
    }
    
    // 인덱스 범위 검증
    if (idx >= _sectionKeys.length) {
      debugPrint('인덱스 범위 초과: $idx >= ${_sectionKeys.length}');
      return;
    }
    
    final ctx = _sectionKeys[idx].currentContext;
    if (ctx != null) {
      debugPrint('스크롤 대상 위젯 발견, 스크롤 시작');
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    } else {
      debugPrint('스크롤 대상 위젯의 context가 null - 재시도 예정');
      // context가 아직 준비되지 않은 경우, 최대 3번까지 재시도
      _retryScrollToCurrent(3);
    }
  }
  
  void _retryScrollToCurrent(int retryCount) {
    if (retryCount <= 0) {
      debugPrint('스크롤 재시도 횟수 초과');
      return;
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      final idx = _currentWeekIndex;
      if (idx < 0 || idx >= _sectionKeys.length) return;
      
      final ctx = _sectionKeys[idx].currentContext;
      if (ctx != null) {
        debugPrint('재시도 성공: 스크롤 시작');
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          alignment: 0.15,
        );
      } else {
        debugPrint('재시도 $retryCount: context 여전히 null');
        _retryScrollToCurrent(retryCount - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주별검사'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _confirmAndInitChecklist,
            icon: const Icon(Icons.restart_alt),
            label: const Text('초기화'),
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
            ),
          ),
          if (_pregnancyWeek != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.primary.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pregnant_woman, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      '임신 ${_pregnancyWeek}주차',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ),
        ],
      ),

      // 본문 리스트 - 모든 위젯을 즉시 렌더링하여 lazy loading 극복
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 오류 메시지 표시
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                        _loadChecklistFromServer(); // 재시도
                      },
                      icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.error, size: 20),
                      tooltip: '다시 시도',
                    ),
                  ],
                ),
              ),
            ...List.generate(
              _weeks.length,
              (index) {
                _ensureWeek(index); // 방어

                final data = _weeks[index];
                final combined = _combinedItems(index);
                return Padding(
                  padding: EdgeInsets.only(bottom: index < _weeks.length - 1 ? 16 : 0),
                  child: _WeekSectionTile(
                    key: _sectionKeys[index],
                    data: data,
                    isFirst: index == 0,
                    isLast: index == _weeks.length - 1,
                    doneCount: _doneCount(index),
                    totalCount: combined.length,
                    onAddCustom: () => _addCustomItem(index),
                    onToggle: (itemIndex) => _toggleDone(index, itemIndex),
                    isItemDone: (itemIndex) => _doneByWeek[index]!.contains(itemIndex),
                    combinedItems: combined,
                    systemCount: data.items.length,
                    onDeleteCustom: (combinedIndex) => _deleteCustomItem(index, combinedIndex),
                    getItemContent: (itemIndex, title) => _getItemContent(index, itemIndex, title),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // ✅ FAB 제거(오른쪽 아래 "임신 n주차로" 버튼 삭제)
      floatingActionButton: null,
    );
  }
}

/// 데이터 모델
class WeekSectionData {
  final String leftTitle; // e.g. "4~6주"
  final String leftSubTitle; // e.g. "임신확인 검사"
  final String range; // e.g. "2025-03-22 ~ 2025-04-11" (현재는 표시 안 함)
  final List<String> items;
  final bool isCurrent;

  const WeekSectionData({
    required this.leftTitle,
    required this.leftSubTitle,
    required this.range,
    required this.items,
    this.isCurrent = false,
  });

  WeekSectionData copyWith({
    String? leftTitle,
    String? leftSubTitle,
    String? range,
    List<String>? items,
    bool? isCurrent,
  }) {
    return WeekSectionData(
      leftTitle: leftTitle ?? this.leftTitle,
      leftSubTitle: leftSubTitle ?? this.leftSubTitle,
      range: range ?? this.range,
      items: items ?? this.items,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

/// 주차별 기본 데이터(현재 주차 표시 전)
const List<WeekSectionData> _weeksMaster = [
  WeekSectionData(
    leftTitle: '1~3주',
    leftSubTitle: '임신 준비·초기',
    range: '예: 2025-03-01 ~ 2025-03-21',
    items: [
      '임신 전 상담 및 복용 약물 점검',
      '엽산 400µg 복용 시작',
      '음주·흡연 중단 및 카페인 줄이기',
      '기저질환(당뇨·갑상선) 관리 상태 확인',
      '예방접종 확인(풍진/수두 등)',
      '생리 지연 시 임신테스트 준비',
    ],
  ),
  WeekSectionData(
    leftTitle: '4~6주',
    leftSubTitle: '임신확인 검사',
    range: '예: 2025-03-22 ~ 2025-04-11',
    items: [
      '초음파 검사',
      '경부암 검사',
      '혈액 임신호르몬 검사',
      '소변 임신테스트 검사',
    ],
  ),
  WeekSectionData(
    leftTitle: '7~9주',
    leftSubTitle: '초기 검사',
    range: '예: 2025-04-12 ~ 2025-05-02',
    items: [
      '초음파 검사',
      '일반 혈액검사 (CBC)',
      '혈액형(ABO/Rh) 검사',
      '불규칙 항체 검사',
      '간기능 검사',
      '갑상선 기능 검사',
      'B형 간염/매독/HIV 등 감염병 선별',
      '소변검사(요단백/세균)',
    ],
  ),
  WeekSectionData(
    leftTitle: '10~13주',
    leftSubTitle: '1차 선별',
    range: '예: 2025-05-03 ~ 2025-05-30',
    items: [
      '목투명대(NT) 초음파',
      '초기 선별검사(PAPP-A, β-hCG)',
      'NIPT(비침습 선별) 선택',
      '풍진 면역 확인',
      '치과 검진·스케일링 권장',
    ],
  ),
  WeekSectionData(
    leftTitle: '14~18주',
    leftSubTitle: '중기 준비',
    range: '예: 2025-05-31 ~ 2025-06-27',
    items: [
      '중기 기본 진료(혈압/체중/요검사)',
      'AFP/쿼드 테스트(15~20주 권장)',
      '정밀초음파 예약',
      '영양·철분 복용 체크',
    ],
  ),
  WeekSectionData(
    leftTitle: '19~22주',
    leftSubTitle: '정밀 초음파',
    range: '예: 2025-06-28 ~ 2025-07-25',
    items: [
      '정밀 기형아 초음파(장기·구조 확인)',
      '자궁경부 길이·태반 위치 확인',
      '자궁동맥 도플러(필요 시)',
    ],
  ),
  WeekSectionData(
    leftTitle: '23~26주',
    leftSubTitle: '중기 점검',
    range: '예: 2025-07-26 ~ 2025-08-22',
    items: [
      '빈혈 재검(CBC)',
      '요검사(요단백/포도당)',
      '철분 복용 순응도 체크',
      'Rh(-) 산모: 28주 항D 예방 주사 예약',
    ],
  ),
  WeekSectionData(
    leftTitle: '24~28주',
    leftSubTitle: '임신성 당뇨',
    range: '예: 2025-08-02 ~ 2025-08-30',
    items: [
      'GCT(50g) 선별검사',
      'OGTT(진단검사, 필요 시)',
      '영양 상담·혈당 관리 교육',
    ],
  ),
  WeekSectionData(
    leftTitle: '27~29주',
    leftSubTitle: '예방접종',
    range: '예: 2025-08-23 ~ 2025-09-12',
    items: [
      'Tdap(파상풍·디프테리아·백일해) 27~36주',
      '인플루엔자 예방접종(유행시즌)',
      'Rh(-) 산모: 항D 면역글로불린(28주)',
      '태동 관찰 교육',
    ],
  ),
  WeekSectionData(
    leftTitle: '30~33주',
    leftSubTitle: '후기 점검',
    range: '예: 2025-09-13 ~ 2025-10-10',
    items: [
      '성장 추적 초음파(필요 시)',
      '빈혈/요단백 재검',
      '분만 계획 상담·병원 등록',
      '산후조리/신생아 용품 준비',
    ],
  ),
  WeekSectionData(
    leftTitle: '34~36주',
    leftSubTitle: '막달 준비',
    range: '예: 2025-10-11 ~ 2025-11-07',
    items: [
      'GBS(35~37주) 선별검사',
      '태위 확인(둔위 시 상담)',
      '출산 가방·동의서 준비',
      '진통·파수 대처 교육',
    ],
  ),
  WeekSectionData(
    leftTitle: '37~40주',
    leftSubTitle: '출산 임박',
    range: '예: 2025-11-08 ~ 2025-12-05',
    items: [
      'NST/태동 검사(필요 시)',
      '진통 간격/활동 지침',
      '유도분만/제왕절개 상담',
      '신생아 접종/출생신고 안내',
    ],
  ),
];

/// 타임라인 섹션
class _WeekSectionTile extends StatelessWidget {
  const _WeekSectionTile({
    super.key,
    required this.data,
    required this.isFirst,
    required this.isLast,
    required this.doneCount,
    required this.totalCount,
    required this.onAddCustom,
    required this.onToggle,
    required this.isItemDone,
    required this.combinedItems,
    required this.systemCount,
    required this.onDeleteCustom,
    required this.getItemContent,
  });

  final WeekSectionData data;
  final bool isFirst;
  final bool isLast;

  final int doneCount;
  final int totalCount;

  final VoidCallback onAddCustom;
  final void Function(int itemIndex) onToggle;
  final bool Function(int itemIndex) isItemDone;

  /// 시스템 + 사용자 합친 리스트와 시스템 항목 개수
  final List<String> combinedItems;
  final int systemCount;

  /// 사용자 항목 삭제 콜백(합쳐진 인덱스 기준)
  final Future<void> Function(int combinedIndex) onDeleteCustom;

  /// 항목 내용 가져오기 콜백
  final String Function(int itemIndex, String title) getItemContent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = data.isCurrent ? cs.secondaryContainer.withOpacity(0.32) : cs.surface;
    final borderColor = Theme.of(context).dividerColor.withOpacity(data.isCurrent ? 0.0 : 0.6);

    final timelineActive = cs.primary;
    final timelineInactive = cs.onSurface.withOpacity(0.18);

    final progress = totalCount == 0 ? 0.0 : (doneCount / totalCount);

    // IntrinsicHeight: 줄바꿈 시 카드 높이에 맞춰 타임라인도 자동 확장
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 좌측 주차 라벨
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.leftTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.leftSubTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 가운데 타임라인
          Container(
            width: 28,
            height: double.infinity,
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  top: isFirst ? 14 : 0,
                  bottom: isLast ? 20 : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      color: data.isCurrent ? timelineActive.withOpacity(0.6) : timelineInactive,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.isCurrent ? timelineActive : timelineInactive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 우측 카드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!Theme.of(context).brightness.isDark)
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  // ✅ 날짜 텍스트 제거: 진행률 + 추가 버튼만 남김
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: Row(
                      children: [
                        // 진행률 칩
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: cs.primary.withOpacity(0.08),
                            ),
                            child: Text(
                              '완료 $doneCount/$totalCount',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: '이 주차에 항목 추가',
                          onPressed: onAddCustom,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: cs.onSurface.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),

                  // 항목 리스트(시스템 + 사용자)
                  ...List.generate(
                    combinedItems.length,
                        (i) {
                      final title = combinedItems[i];
                      final isUser = i >= systemCount;
                      return _CheckRow(
                        index: i,
                        title: title,
                        done: isItemDone(i),
                        isUserItem: isUser,
                        onTap: () => onToggle(i),
                        onInfoTap: () => _showDetailBottomSheet(
                          context,
                          title,
                          getItemContent(i, title),
                        ),
                        onDelete: isUser ? () => onDeleteCustom(i) : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.index,
    required this.title,
    required this.done,
    required this.onTap,
    this.onInfoTap,
    this.isUserItem = false,
    this.onDelete,
  });

  final int index;
  final String title;
  final bool done;
  final bool isUserItem;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap; // 사용자 항목은 null
  final Future<void> Function()? onDelete;  // 사용자 항목에서만 사용

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: () {
        if (onInfoTap != null) {
          onInfoTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 체크박스 아이콘
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: done ? 1.0 : 0.9,
              child: Icon(
                done ? Icons.check_box : Icons.check_box_outline_blank,
                color: done ? cs.primary : cs.onSurface.withOpacity(0.35),
              ),
            ),
            const SizedBox(width: 12),

            // 제목
            Expanded(
              child: Row(
                children: [
                  if (isUserItem)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.person, size: 16, color: cs.onSurface.withOpacity(0.65)),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      softWrap: true,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        color: cs.onSurface,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: cs.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 트레일링: 상세 보기 버튼과 삭제 버튼
            if (onInfoTap != null)
              IconButton(
                onPressed: onInfoTap,
                icon: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.55)),
                tooltip: '상세 보기',
              ),
            if (onDelete != null)
              IconButton(
                onPressed: () => onDelete!(),
                icon: Icon(Icons.delete_outline, color: cs.onSurface.withOpacity(0.55)),
                tooltip: '삭제',
              ),
          ],
        ),
      ),
    );
  }
}

/// 상세 바텀시트
void _showDetailBottomSheet(
    BuildContext context,
    String title,
    String body,
    ) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.35,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: Icon(Icons.close, color: cs.onSurface),
                        tooltip: '닫기',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 본문
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(
                      body,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: cs.onSurface.withOpacity(0.95),
                      ),
                    ),
                  ),
                ),

                // 디스클레이머
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    '※ 본 앱의 정보는 교육 목적이며, 개인의 의학적 판단은 담당 의료진과 상의하세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// brightness helper
extension on Brightness {
  bool get isDark => this == Brightness.dark;
}
