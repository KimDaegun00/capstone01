// lib/detail_screens/checklist_screen.dart
import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _sectionKeys;
  final Map<int, Set<int>> _doneByWeek = {}; // weekIndex -> set of itemIndex

  int get _currentWeekIndex => _weeks.indexWhere((w) => w.isCurrent);

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(_weeks.length, (_) => GlobalKey());
    for (int i = 0; i < _weeks.length; i++) {
      _doneByWeek[i] = <int>{};
    }
  }

  void _toggleDone(int weekIndex, int itemIndex) {
    final set = _doneByWeek[weekIndex]!;
    set.contains(itemIndex) ? set.remove(itemIndex) : set.add(itemIndex);
    setState(() {});
  }

  int _doneCount(int weekIndex) => _doneByWeek[weekIndex]!.length;

  void _scrollToCurrent() {
    final idx = _currentWeekIndex;
    if (idx < 0) return;
    final ctx = _sectionKeys[idx].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }
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
      ),
      body: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: _weeks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final data = _weeks[index];
          return _WeekSectionTile(
            key: _sectionKeys[index],
            data: data,
            isFirst: index == 0,
            isLast: index == _weeks.length - 1,
            doneCount: _doneCount(index),
            onToggle: (itemIndex) => _toggleDone(index, itemIndex),
            isItemDone: (itemIndex) => _doneByWeek[index]!.contains(itemIndex),
          );
        },
      ),
      floatingActionButton: _currentWeekIndex >= 0
          ? FloatingActionButton.extended(
        onPressed: _scrollToCurrent,
        icon: const Icon(Icons.my_location),
        label: const Text('현재 주로'),
      )
          : null,
    );
  }
}

/// 데이터 모델
class WeekSectionData {
  final String leftTitle; // e.g. "4~6주"
  final String leftSubTitle; // e.g. "임신확인 검사"
  final String range; // e.g. "2025-03-22 ~ 2025-04-11"
  final List<String> items;
  final bool isCurrent;

  const WeekSectionData({
    required this.leftTitle,
    required this.leftSubTitle,
    required this.range,
    required this.items,
    this.isCurrent = false,
  });
}

/// 주차별 더미 데이터 (1~40주)
const List<WeekSectionData> _weeks = [
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
    isCurrent: true, // 데모용
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
    required this.onToggle,
    required this.isItemDone,
  });

  final WeekSectionData data;
  final bool isFirst;
  final bool isLast;

  final int doneCount;
  final void Function(int itemIndex) onToggle;
  final bool Function(int itemIndex) isItemDone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg =
    data.isCurrent ? cs.secondaryContainer.withOpacity(0.32) : cs.surface;
    final borderColor =
    Theme.of(context).dividerColor.withOpacity(data.isCurrent ? 0.0 : 0.6);

    final timelineActive = cs.primary;
    final timelineInactive = cs.onSurface.withOpacity(0.18);

    final total = data.items.length;
    final progress = total == 0 ? 0.0 : (doneCount / total);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        SizedBox(
          width: 28,
          height: _calcHeightForItems(data.items.length),
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
                    color: data.isCurrent
                        ? timelineActive.withOpacity(0.6)
                        : timelineInactive,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                    data.isCurrent ? timelineActive : timelineInactive,
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                // 날짜 범위 + 진행률 (오버플로우 방지 버전)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            // 텍스트가 길어도 말줄임으로 처리
                            child: Text(
                              data.range,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                color: cs.primary.withOpacity(0.08),
                              ),
                              child: Text(
                                '완료 $doneCount/$total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor:
                          cs.onSurface.withOpacity(0.08),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(cs.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Divider(height: 1),

                // 항목
                ...List.generate(
                  data.items.length,
                      (i) => _CheckRow(
                    index: i,
                    title: data.items[i],
                    done: isItemDone(i),
                    onTap: () => onToggle(i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _calcHeightForItems(int count) {
    // 진행률 UI를 고려한 대략적 높이
    const perRow = 56.0;
    const header = 86.0;
    const padding = 24.0;
    return header + (count * perRow) + padding;
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.index,
    required this.title,
    required this.done,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\'$title\' 상세는 준비 중입니다')),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          minLeadingWidth: 0,
          leading: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: done ? 1.0 : 0.9,
            child: Icon(
              // ⬇️ 원형 → 정사각형 체크박스
              done ? Icons.check_box : Icons.check_box_outline_blank,
              color: done ? cs.primary : cs.onSurface.withOpacity(0.35),
            ),
          ),
          title: Text(
            title,
            maxLines: 1, // 긴 텍스트 대비
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: cs.onSurface.withOpacity(0.35),
            ),
          ),
          trailing: Icon(Icons.chevron_right,
              color: cs.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }
}

/// brightness helper
extension on Brightness {
  bool get isDark => this == Brightness.dark;
}
