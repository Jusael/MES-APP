import 'package:flutter/material.dart';
import 'package:mes_mobile_app/dtos/alarm_dto.dart';
import 'package:mes_mobile_app/dtos/sign_dto.dart';
import 'package:mes_mobile_app/database/alarm_database.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mes_mobile_app/styles/text_styles.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mes_mobile_app/database/alarm_repository.dart';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:mes_mobile_app/screens/alarm/alarm_list_control.dart';

final AlarmController _alarmController = AlarmController();
final ScrollController _scrollController = ScrollController();

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  final int? reciveIndex = null;

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();

}



class _AlarmListScreenState extends State<AlarmListScreen> {
  List<AlarmBasic> alarms = [];
  final RefreshController _refreshController = RefreshController();
  int? expandedAlarmId; // 어떤 알람이 확장되었는지 추적
  int? _focusAlarmId; // 앱 알람 클릭으로 들어온경우 해당 화면을 열도록

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int? focusId = ModalRoute.of(context)?.settings.arguments as int?;
      if (focusId != null) {
        setState(() {
          expandedAlarmId  = focusId;
        });
      }
    });

    this.loadInittialDate();
  }

  Future<void> loadInittialDate() async{
    await insertUnreadAlarm();
    await loadAlarms();
  }

  Future<void> scrollToFocusedItem() async {
    if (expandedAlarmId == null) return;

    final index = alarms.indexWhere((alarm) => alarm.appAlarmId == expandedAlarmId);
    if (index != -1) {
      // 프레임 렌더링 이후 스크롤 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          index * 135,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> insertUnreadAlarm() async {
    final storage = FlutterSecureStorage();
    final String? userId = await storage.read(key: 'user_id');
    print("🔵 userId : ${userId}");

    final response = await ApiService.get(
      '/api/alarm/getincomingalarmbutunread',
      queryParams: {'UserId': userId ?? ''},
    );

    // 3. 받아온 알람들을 저장
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body['success']) {
        final List<dynamic> alarmList = body['alarms'];

        final alarmRepository = AlarmRepository();
        for (final alarmJson in alarmList) {
          final alarm = AlarmBasic.fromMap(alarmJson);
          await alarmRepository.insertAlarmIfNotExists(alarm);
        }
      }
    }
  }


  // 전체 알람 조회
  Future<void> loadAlarms() async {
    final db = AlarmDatabase();
    final maps = await db.getAllAlarms();

    //db 에서 조회시 카멜 형식이어 AlarmBasic으로 변경하는 Map
    final searchAlarms = maps.map((map) => AlarmBasic.dataBaseMap(map)).toList();

    setState(() {
      alarms = searchAlarms;
    });

    await scrollToFocusedItem();  // ✅ 알람 불러온 후 포커스 이동 시도

    _refreshController.refreshCompleted();
  }

  // 알림 읽음 처리
  Future<void> markAsRead(int index) async {
    
    final db = AlarmDatabase();
    final alarm = alarms[index];

    if (alarm.readYn != 'Y') {
      alarm.readYn = 'Y';
      await db.markAsRead(alarm.id);
      setState(() {});
    }
  }

  // 알림 개별 삭제
  Future<void> deleteAlarm(int index) async {
    final deleteConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("삭제 확인"),
        content: const Text("해당 알림을 삭제할까요?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
        ],
      ),
    );

    if (deleteConfirm == true) {

      await _alarmController.postUpdateAlarmStatus(context, alarms[index].appAlarmId.toString(), 'DELETE');

      final db = AlarmDatabase();
      await db.deleteAlarm(alarms[index].appAlarmId);
      setState(() {
        alarms.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacementNamed(context, '/home');
      return false;
    },
    child:  Scaffold(
      appBar: AppBar(
        title: const Text("알람 목록", style: AppTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 94, 176, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 항상 알람리스트로 이동
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: loadAlarms,
        header: const WaterDropHeader(
          complete: SizedBox.shrink(),
          failed: SizedBox.shrink(),
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            final alarm = alarms[index];
            final isRead = alarm.readYn == 'Y';
            final isExpanded =  (alarm.appAlarmId == expandedAlarmId);

            return GestureDetector(
              onTap: () async {
                await markAsRead(index);
                if (alarm.signCd?.trim().isNotEmpty == true) {
                  // 전자서명 알림: 화면 전환
                  final sign = SignDto.fromAlarm(alarm);
                  Navigator.pushNamed(context, '/sign', arguments: sign);
                } else {
                  
                  //일반 알람은 알람리스트에서 읽음처리
                  // 전자서명은 전자서명 화면에서 읽음 처리
                  await _alarmController.postUpdateAlarmStatus(context, alarm.appAlarmId.toString(), 'READ');
                  
                  // 일반 알림: 확장/축소 토글
                  setState(() {
                    expandedAlarmId = (expandedAlarmId == alarm.appAlarmId) ? null : alarm.appAlarmId;
                  });
                }
              },
              onLongPress: () => deleteAlarm(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [

                        const Icon(Icons.notifications, color: Colors.black),
                        const SizedBox(width: 8),
                        Expanded(

                          child: Text(
                            alarm.title == null ? '' :alarm.title! ,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextLine(alarm.content1),
                    _buildTextLine(alarm.content2),
                    if (isExpanded) ...[
                      const Divider(),
                      _buildTextLine(alarm.content3),
                      _buildTextLine(alarm.content4),
                      _buildTextLine(alarm.content5),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              expandedAlarmId = null;
                            });
                          },
                          child: const Text("닫기"),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("전체 삭제 확인"),
              content: const Text("모든 알림을 삭제하시겠습니까?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
              ],
            ),
          );

          if (confirm == true) {

            alarms.forEach ((alarm) async =>
                await _alarmController.postUpdateAlarmStatus(context, alarm.appAlarmId.toString(), 'DELETE')
            );

            final db = AlarmDatabase();
            await db.deleteAllAlarm();
            setState(() {
              alarms.clear();
              expandedAlarmId = null;
            });
          }
        },
        backgroundColor: const Color.fromARGB(255, 93, 163, 220),
        child: const Icon(Icons.delete),
        tooltip: '전체 삭제',
      ),
    )
    );
  }

  Widget _buildTextLine(String? text) {
    if (text == null || text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text.trim(), style: AppTextStyles.body),
    );
  }
}
