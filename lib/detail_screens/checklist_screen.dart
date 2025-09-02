// lib/detail_screens/checklist_screen.dart
import 'package:flutter/material.dart';

/// 항목 제목 → 상세 텍스트 매핑 (2~3줄 요약)
/// pubspec/assets 수정 없이, 이 파일 하나만으로 동작합니다.
const Map<String, String> _detailsByTitle = {
  // 1~3주
  '임신 전 상담 및 복용 약물 점검':
  '임신 전·초기에는 일부 약물이 태아에 영향을 줄 수 있어요. '
      '현재 복용 중인 처방약/한약/영양제 리스트를 의료진에게 공유하고, '
      '중단·변경은 반드시 상담 후 진행하세요.',
  '엽산 400µg 복용 시작':
  '엽산은 태아 신경관 결손 위험을 낮추는 데 중요해요. '
      '임신 전부터 임신 12주까지 매일 400µg 섭취가 권장됩니다.',
  '음주·흡연 중단 및 카페인 줄이기':
  '음주·흡연은 유산·저체중아 등 위험을 높일 수 있어요. '
      '카페인은 1일 200mg 이하(커피 1~2잔 수준)로 줄이는 게 좋아요.',
  '기저질환(당뇨·갑상선) 관리 상태 확인':
  '당뇨·갑상선 등 기저질환을 안정화하면 임신 합병증 위험을 낮출 수 있어요. '
      '복용 약이 임신에 적합한지 의료진과 확인하세요.',
  '예방접종 확인(풍진/수두 등)':
  '풍진·수두 항체가 없으면 임신 전 접종이 권장돼요. '
      '생백신은 임신 중 금기이니 시기와 종류를 꼭 확인하세요.',
  '생리 지연 시 임신테스트 준비':
  '배란 후 약 2주 전후부터 가정용 소변 hCG 검사로 확인이 가능해요. '
      '음성이라도 의심되면 며칠 뒤 재검하거나 의료진 상담을 권장해요.',

  // 4~6주
  '초음파 검사':
  '임신 초기 초음파는 자궁내 임신 여부와 임신 주수를 확인하는 데 사용돼요. '
      '보통 6주 전후에 시행하며, 필요 시 추적 검사를 할 수 있어요.',
  '경부암 검사':
  '자궁경부 세포를 채취해 전암 병변 여부를 확인하는 선별검사예요. '
      '임신 중에도 비교적 안전하게 시행할 수 있습니다.',
  '혈액 임신호르몬 검사':
  '혈중 β-hCG 수치로 임신 진행을 평가해요. '
      '수치 단독보다 초음파 소견과 함께 해석합니다.',
  '소변 임신테스트 검사':
  '간편한 가정용 검사로 임신 여부를 선별해요. '
      '아침 첫 소변에서 정확도가 더 높습니다.',

  // 7~9주
  '일반 혈액검사 (CBC)':
  '빈혈·감염 등 전반 상태를 확인하는 기본 혈액검사예요. '
      '임신 중 체내 변화 확인 및 이후 비교 지표로 활용됩니다.',
  '혈액형(ABO/Rh) 검사':
  '엄마의 ABO/Rh 혈액형을 확인해 수혈·산과적 처치에 대비해요. '
      'Rh(-)인 경우 이후 항D 예방 주사 계획에 중요합니다.',
  '불규칙 항체 검사':
  '수혈·신생아 용혈 등 문제를 일으킬 수 있는 항체 유무를 확인해요. '
      'Rh 부적합 등 위험을 조기에 파악하는 데 도움됩니다.',
  '간기능 검사':
  '간 효소 수치 등으로 간 기능 이상 여부를 확인해요. '
      '임신 중 약물 복용·간질환 병력 등이 있으면 특히 중요합니다.',
  '갑상선 기능 검사':
  'TSH/T4 등으로 갑상선 기능을 확인해요. '
      '임신 중 갑상선 이상은 태아 발달에 영향을 줄 수 있어 조기 평가가 좋아요.',
  'B형 간염/매독/HIV 등 감염병 선별':
  '주요 감염병 보유 여부를 확인해 산모·태아 관리 계획을 세워요. '
      '양성 시 전염 예방 및 산과적 조치가 매우 중요합니다.',
  '소변검사(요단백/세균)':
  '요로감염·단백뇨 등 여부를 확인해요. '
      '무증상 세균뇨도 임신 중 합병증과 연관되어 조기 치료가 필요할 수 있어요.',

  // 10~13주
  '목투명대(NT) 초음파':
  '태아 목덜미 두께를 측정해 염색체 이상 가능성을 선별해요. '
      '보통 11~13+6주 사이에 시행합니다.',
  '초기 선별검사(PAPP-A, β-hCG)':
  '혈액 표지자와 NT를 종합해 염색체 이상 위험도를 평가해요. '
      '양성 시 추가 정밀 검사를 고려합니다.',
  'NIPT(비침습 선별) 선택':
  '모체 혈액에서 태아 DNA를 분석해 염색체 이상을 선별해요. '
      '정확도가 높지만 확진 검사는 아니며, 결과에 따라 상담이 필요합니다.',
  '풍진 면역 확인':
  '풍진 항체를 확인해 면역 여부를 파악해요. '
      '면역이 없다면 임신 전 접종이 필요하고, 임신 중에는 노출 예방이 중요해요.',
  '치과 검진·스케일링 권장':
  '임신 중 잇몸질환은 조산 위험과 연관될 수 있어요. '
      '통증·염증이 있으면 적절한 시기에 치료가 가능합니다.',

  // 14~18주
  '중기 기본 진료(혈압/체중/요검사)':
  '정기 진료로 혈압·체중·소변 등을 확인해 임신 경과를 모니터링해요. '
      '이상 소견은 조기 개입에 도움이 됩니다.',
  'AFP/쿼드 테스트(15~20주 권장)':
  '혈중 표지자(AFP 등)로 신경관 결손·일부 염색체 이상 위험을 선별해요. '
      '양성 시 정밀 초음파 등 추가 평가를 권장합니다.',
  '정밀초음파 예약':
  '장기 구조·발달을 자세히 보는 검사를 예약해요. '
      '주수 적정 시기에 시행하면 이상 발견에 도움이 됩니다.',
  '영양·철분 복용 체크':
  '임신기 권장 영양소 섭취와 철분 보충 상태를 점검해요. '
      '빈혈 예방과 피로 완화에 도움됩니다.',

  // 19~22주
  '정밀 기형아 초음파(장기·구조 확인)':
  '뇌·심장·척추 등 주요 장기 구조를 상세히 확인해요. '
      '각 장기의 발달과 이상 유무를 평가하는 핵심 검사입니다.',
  '자궁경부 길이·태반 위치 확인':
  '조산 위험(자궁경부 짧음)과 전치태반 등 위치 이상을 확인해요. '
      '이상 시 추가 관찰·치료 계획을 세웁니다.',
  '자궁동맥 도플러(필요 시)':
  '태반 혈류 상태를 평가해 자간전증·태아발육지연 위험을 가늠해요. '
      '필요 시 정밀 추적 관찰을 병행합니다.',

  // 23~26주
  '빈혈 재검(CBC)':
  '중기 이후 빈혈 여부를 다시 확인해요. '
      '필요하면 철분 용량·복용 스케줄을 조정합니다.',
  '요검사(요단백/포도당)':
  '단백뇨·포도당뇨 등 여부를 확인해 자간전증·당대사 이상 등을 추적해요.',
  '철분 복용 순응도 체크':
  '복용 시간·부작용(변비 등)을 확인하고 복용법을 조정해요. '
      '흡수율을 높이는 팁(비타민C 동시 섭취 등)을 안내합니다.',
  'Rh(-) 산모: 28주 항D 예방 주사 예약':
  '산모가 Rh(-)이고 아기 아빠가 Rh(+)일 수 있으면, '
      '감작 예방을 위해 28주 전후 항D 면역글로불린 주사를 계획해요.',

  // 24~28주
  'GCT(50g) 선별검사':
  '임신성 당뇨 선별을 위한 50g 포도당 부하 검사예요. '
      '기준치 초과 시 진단 검사(OGTT)를 시행합니다.',
  'OGTT(진단검사, 필요 시)':
  '선별 양성 시 75g 또는 100g OGTT로 확진을 해요. '
      '결과에 따라 식이·운동·약물 치료를 결정합니다.',
  '영양 상담·혈당 관리 교육':
  '식사 구성·간식·활동량을 조정해 혈당을 안정화하는 방법을 안내해요. '
      '자가혈당 측정이 필요한 경우 방법을 교육합니다.',

  // 27~29주
  'Tdap(파상풍·디프테리아·백일해) 27~36주':
  '신생아 백일해 예방을 위해 27~36주 사이 Tdap 접종이 권장돼요. '
      '엄마 항체가 아기에게 전달돼 초기 보호에 도움됩니다.',
  '인플루엔자 예방접종(유행시즌)':
  '임신부는 독감 합병증 위험이 높아 접종이 권장돼요. '
      '불활성화 백신을 사용하며, 유행 시즌 전에 맞는 게 좋아요.',
  'Rh(-) 산모: 항D 면역글로불린(28주)':
  'Rh(-) 산모의 감작 예방을 위해 28주 전후 항D 주사를 투여해요. '
      '분만·출혈·침습적 시술 시 추가 투여가 필요할 수 있어요.',
  '태동 관찰 교육':
  '규칙적으로 태동을 느끼는지 확인하고, 감소 시 즉시 내원하도록 교육해요. '
      '개인차가 있어 평소 패턴을 아는 것이 중요합니다.',

  // 30~33주
  '성장 추적 초음파(필요 시)':
  '태아 추정체중·양수량·혈류 등을 확인해 성장 상태를 추적해요. '
      '발육지연 의심 시 관찰 간격을 조정합니다.',
  '빈혈/요단백 재검':
  '후기에도 빈혈·단백뇨 여부를 점검해 합병증 신호를 조기에 발견해요.',
  '분만 계획 상담·병원 등록':
  '분만 방식·동의서·동반자·통증조절 등 계획을 상의하고, '
      '분만 예정 병원 등록/투어를 준비해요.',
  '산후조리/신생아 용품 준비':
  '산후 회복·모유수유 환경을 준비하고, '
      '기저귀·카시트 등 필수 용품 체크리스트를 점검해요.',

  // 34~36주
  'GBS(35~37주) 선별검사':
  '그룹 B 연쇄구균 보균 여부를 확인해요. '
      '양성이면 분만 중 항생제 투여로 신생아 감염을 예방합니다.',
  '태위 확인(둔위 시 상담)':
  '아기 머리 위치(두정/둔위)를 확인해요. '
      '둔위면 외회전술 가능 여부나 분만 방식에 대해 상담합니다.',
  '출산 가방·동의서 준비':
  '필요 서류·세면도구·산모·신생아 용품을 미리 챙겨요. '
      '분만 동의서·기증 동의 등 서류도 함께 준비합니다.',
  '진통·파수 대처 교육':
  '규칙적 진통 간격·파수 의심 시 병원 연락/내원 기준을 안내해요. '
      '출혈·심한 통증·태동 감소 등 경고 신호도 숙지합니다.',

  // 37~40주
  'NST/태동 검사(필요 시)':
  '태아 심박·활동을 모니터링해 안녕 상태를 확인해요. '
      '고위험군이나 태동 감소 시 시행을 고려합니다.',
  '진통 간격/활동 지침':
  '초산부는 규칙적 진통이 5분 간격 내외로 1시간 지속되면 내원을 권장해요. '
      '물 샘 의심·심한 통증·출혈 등은 즉시 병원으로 가세요.',
  '유도분만/제왕절개 상담':
  '주수·산모·태아 상태에 따라 유도분만이나 수술 여부를 상의해요. '
      '장단점·위험·회복 과정을 미리 이해하면 도움이 됩니다.',
  '신생아 접종/출생신고 안내':
  'BCG 등 초기 예방접종 일정과 출생등록 절차를 안내해요. '
      '필수 서류·기한을 확인해 누락을 방지하세요.',
};

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

/// 주차별 더미 데이터 (1~40주 범위를 구간으로 묶어 표현)
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
                  // 날짜 범위 + 진행률
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
                            backgroundColor: cs.onSurface.withOpacity(0.08),
                            valueColor:
                            AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),

                  // 항목 리스트
                  ...List.generate(
                    data.items.length,
                        (i) => _CheckRow(
                      index: i,
                      title: data.items[i],
                      done: isItemDone(i),
                      onTap: () => onToggle(i),
                      onInfoTap: () => _showDetailBottomSheet(
                        context,
                        data.items[i],
                        _detailsByTitle[data.items[i]] ??
                            '해당 항목의 요약 정보는 준비 중입니다.\n'
                                '필요시 의료진과 상담을 권장드립니다.',
                      ),
                    ),
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
    required this.onInfoTap,
  });

  final int index;
  final String title;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\'$title\' 상세는 준비 중입니다')),
      ),
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

            // 제목 (자동 줄바꿈 허용)
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

            const SizedBox(width: 8),

            // 상세 보기 아이콘
            IconButton(
              onPressed: onInfoTap,
              icon: Icon(Icons.chevron_right,
                  color: cs.onSurface.withOpacity(0.55)),
              tooltip: '상세 보기',
            ),
          ],
        ),
      ),
    );
  }
}

/// 상세 바텀시트: 같은 파일 안에서 처리
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
