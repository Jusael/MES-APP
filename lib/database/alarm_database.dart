import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mes_mobile_app/dtos/alarm_dto.dart'; // AlarmBasic 정의된 곳

class AlarmDatabase {
  // AlarmDatabase()를 계속 호출해도, 항상 딱 하나만 만들어서 같은 거 돌려주는 방식이라고 하는데. 그냥 외우자
  static final AlarmDatabase _instance = AlarmDatabase._internal(); // 클래스 안에서 딱 한 번만 만들어질 인스턴스를 선언
  factory AlarmDatabase() => _instance; // 생성자 호출 시 기존 인스턴스를 반환 (new로 여러 번 호출해도 동일 인스턴스)
  AlarmDatabase._internal(); // 외부에서 접근 불가한 내부 전용 생성자 (직접 new AlarmDatabase()는 못함)

  static Database? _db;

  //! 구문은 null이 아님을 보장하는 Dart의 null safety 연산자
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // 실제 DB 초기화
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarm.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            app_alarm_id INTEGER,
            mes_alarm_id INTEGER,
            user_id TEXT,
            user_nm TEXT,
            title TEXT,
            content1 TEXT,
            content2 TEXT,
            content3 TEXT,
            content4 TEXT,
            content5 TEXT,
            sign_cd TEXT,
            sign_id TEXT,
            key1 TEXT,
            key2 TEXT,
            key3 TEXT,
            key4 TEXT,
            key5 TEXT,
            create_time TEXT,
            read_yn TEXT DEFAULT 'N'
          )
        ''');
      },
    );
  }

  // 🔹 알림 1건 저장 (FCM 수신 후 호출됨)
  Future<void> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await database;
    print(alarm.keys);
    final appAlarmId = alarm['app_alarm_id'];

    // 이미 존재하는지 수동 체크
    final existing = await db.query(
      'alarms',
      where: 'app_alarm_id = ?',
      whereArgs: [appAlarmId],
    );

    if (existing.isEmpty) {
      await db.insert('alarms', alarm);
      print('✅ insertAlarm 저장됨: $appAlarmId');
    } else {
      print('⏩ 중복 건너뜀: $appAlarmId');
    }
  }

  // 🔹 알림 전체 조회
  Future<List<Map<String, dynamic>>> getAllAlarms() async {
    final db = await database;
    return await db.query('alarms', orderBy: 'create_time DESC');
  }

  // 🔹 알림 읽음 처리 (read_yn = 'Y') — 알람 리스트에서 탭 시 호출됨
  Future<void> markAsRead(int? id) async {
    final db = await database;
    await db.update(
      'alarms',
      {'read_yn': 'Y'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ 알림 삭제 처리 — app_alarm_id 기준
  Future<void> deleteAlarm(int? id) async {
    final db = await database;
    await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // ✅ 알림 삭제 처리 — app_alarm_id 기준
  Future<void> deleteAllAlarm() async {
    final db = await database;
    await db.delete(
      'alarms',
    );
  }


}
