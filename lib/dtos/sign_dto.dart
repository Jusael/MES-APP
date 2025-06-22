
import 'package:mes_mobile_app/dtos/alarm_dto.dart'; // AlarmBasic 정의된 곳

class SignDto {
  final int? id;
  final int? appAlarmId;
  final int? mesAlarmId;
  final String userId;
  final String userNm;
  final String title;
  final String content1;
  final String content2;
  final String content3;
  final String content4;
  final String content5;
  final String signCd;
  final String signId;
  final String key1;
  final String key2;
  final String key3;
  final String key4;
  final String key5;
  final String createTime;
  final String readYn;

  SignDto({
    this.id,
    this.appAlarmId,
    this.mesAlarmId,
    required this.userId,
    required this.userNm,
    required this.title,
    required this.content1,
    required this.content2,
    required this.content3,
    required this.content4,
    required this.content5,
    required this.signCd,
    required this.signId,
    required this.key1,
    required this.key2,
    required this.key3,
    required this.key4,
    required this.key5,
    required this.createTime,
    required this.readYn,
  });

  factory SignDto.fromAlarm(AlarmBasic alarm) {
    if (alarm.signCd == null || alarm.signId == null) {
      throw Exception("전자서명 정보가 없습니다.");
    }

    return SignDto(
      id: alarm.id,
      appAlarmId: alarm.appAlarmId,
      mesAlarmId: alarm.mesAlarmId,
      userId: alarm.userId ?? '',
      userNm: alarm.userNm ?? '',
      title: alarm.title ?? '',
      content1: alarm.content1 ?? '',
      content2: alarm.content2 ?? '',
      content3: alarm.content3 ?? '',
      content4: alarm.content4 ?? '',
      content5: alarm.content5 ?? '',
      signCd: alarm.signCd!,
      signId: alarm.signId!,
      key1: alarm.key1 ?? '',
      key2: alarm.key2 ?? '',
      key3: alarm.key3 ?? '',
      key4: alarm.key4 ?? '',
      key5: alarm.key5 ?? '',
      createTime: alarm.createTime ?? '',
      readYn: alarm.readYn ?? 'N',
    );
  }
}