import 'package:firebase_messaging/firebase_messaging.dart';
import 'alarm_database.dart';
import 'package:mes_mobile_app/dtos/alarm_dto.dart';

class AlarmRepository {
  final _db = AlarmDatabase();

  //메세지를 받아 db에 저장
  //상기 _db 가 final임으로 static 사용은 못함
  Future<void> saveAlarmFromFCM(RemoteMessage message) async {
    final data = message.data;

    final alarm = {
      'app_alarm_id': int.tryParse(data['appAlarmId'] ?? '0'),
      'user_id': data['userId'] ?? '',
      'user_nm': data['userNm'] ?? '',
      'title': data['title'] ?? '',
      'content1': data['content1'] ?? '',
      'content2': data['content2'] ?? '',
      'content3': data['content3'] ?? '',
      'content4': data['content4'] ?? '',
      'content5': data['content5'] ?? '',
      'sign_cd': data['signCd'] ?? '',
      'sign_id': data['signId'] ?? '',
      'key1': data['key1'] ?? '',
      'key2': data['key2'] ?? '',
      'key3': data['key3'] ?? '',
      'key4': data['key4'] ?? '',
      'key5': data['key5'] ?? '',
      'create_time': DateTime.now().toIso8601String(),
      'read_yn': 'N',
    };

    await _db.insertAlarm(alarm);
    print(' 알림 저장 완료 (repository)');
  }

  Future<void> insertAlarmIfNotExists(AlarmBasic alarm) async {
    await _db.insertAlarm(alarm.toMap());
  }

  Future<int> countUnreadAlarms({required bool signOnly}) async {
    final db = await AlarmDatabase().database;
    String where = "read_yn = 'N'";
    if (signOnly) {
      where += " AND sign_cd IS NOT NULL";
    } else {
      where += " AND sign_cd IS NULL";
    }
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM alarms WHERE $where");

    if (result.isNotEmpty && result[0]['count'] != null) {
      return result[0]['count'] as int;
    } else {
      return 0;
    }
  }
}
