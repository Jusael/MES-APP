
class AlarmBasic {
  final int? id;
  final int? appAlarmId;
  final int? mesAlarmId;
  final String? userId;
  final String? userNm;
  final String? title;
  final String? content1;
  final String? content2;
  final String? content3;
  final String? content4;
  final String? content5;
  final String? signCd;
  final String? signId;
  final String? key1;
  final String? key2;
  final String? key3;
  final String? key4;
  final String? key5;
  final String? createTime;
  String? readYn;

  AlarmBasic({
    this.id,
    this.appAlarmId,
    this.mesAlarmId,
    this.userId,
    this.userNm,
    this.title,
    this.content1,
    this.content2,
    this.content3,
    this.content4,
    this.content5,
    this.signCd,
    this.signId,
    this.key1,
    this.key2,
    this.key3,
    this.key4,
    this.key5,
    this.createTime,
    this.readYn,
  });


  factory AlarmBasic.fromMap(Map<String, dynamic> map) {
    return AlarmBasic(
      id: map['id'] as int?,
      //DB에서 조회시 int 지만, 알람을 통해 넘어온 경우 string 고정이기에 형변환 진행
      appAlarmId: map['appAlarmId'] is int
          ? map['appAlarmId']
          : int.tryParse(map['appAlarmId'] ?? ''),
      mesAlarmId: map['mesAlarmId'] is int
          ? map['mesAlarmId']
          : int.tryParse(map['mesAlarmId'] ?? ''),
      userId: map['userId'] as String?,
      userNm: map['userNm'] as String?,
      title: map['title'] as String,
      content1: map['content1'] as String?,
      content2: map['content2'] as String?,
      content3: map['content3'] as String?,
      content4: map['content4'] as String?,
      content5: map['content5'] as String?,
      signCd: map['signCd'] as String?,
      signId: map['signId'] as String?,
      key1: map['key1'] as String?,
      key2: map['key2'] as String?,
      key3: map['key3'] as String?,
      key4: map['key4'] as String?,
      key5: map['key5'] as String?,
      createTime: map['create_time'] as String?,
      readYn: map['read_yn'] as String?,
    );
  }

  factory AlarmBasic.dataBaseMap(Map<String, dynamic> map) {
    print(map.keys);

    return AlarmBasic(

      id: map['id'] as int?,
      //DB에서 조회시 int 지만, 알람을 통해 넘어온 경우 string 고정이기에 형변환 진행
      appAlarmId: map['app_alarm_id'] is int
          ? map['app_alarm_id']
          : int.tryParse(map['app_alarm_id'] ?? ''),
      mesAlarmId: map['mes_alarm_id'] is int
          ? map['mes_alarm_id']
          : int.tryParse(map['mes_alarm_id'] ?? ''),
      userId: map['user_id'] as String?,
      userNm: map['user_nm'] as String?,
      title: map['title'] as String?,
      content1: map['content1'] as String?,
      content2: map['content2'] as String?,
      content3: map['content3'] as String?,
      content4: map['content4'] as String?,
      content5: map['content5'] as String?,
      signCd: map['sign_cd'] as String?,
      signId: map['sign_id'] as String?,
      key1: map['key1'] as String?,
      key2: map['key2'] as String?,
      key3: map['key3'] as String?,
      key4: map['key4'] as String?,
      key5: map['key5'] as String?,
      createTime: map['create_time'] as String?,
      readYn: map['read_yn'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_alarm_id': appAlarmId,
      'mes_alarm_id': mesAlarmId,
      'user_id': userId ?? '',
      'user_nm': userNm ?? '',
      'title': title ?? '',
      'content1': content1 ?? '',
      'content2': content2 ?? '',
      'content3': content3 ?? '',
      'content4': content4 ?? '',
      'content5': content5 ?? '',
      'sign_cd': signCd ?? '',
      'sign_id': signId ?? '',
      'key1': key1 ?? '',
      'key2': key2 ?? '',
      'key3': key3 ?? '',
      'key4': key4 ?? '',
      'key5': key5 ?? '',
      'create_time': createTime ?? DateTime.now().toIso8601String(),
      'read_yn': readYn ?? 'N',
    };
  }
}