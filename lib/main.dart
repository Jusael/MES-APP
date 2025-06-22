import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mes_mobile_app/screens/sign/sign_confirm_wrapper.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/login_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/alarm/alarm_list_screen.dart';
import 'screens/putaway_picking/putaway_picking_screen.dart';
import 'screens/sign/sign_confirm_screen.dart';
import 'screens/home/home_screen.dart';
import 'database/alarm_database.dart';
import 'database/alarm_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:mes_mobile_app/splash/splash_screen.dart';
import 'package:mes_mobile_app/dtos/alarm_dto.dart';
import 'package:mes_mobile_app/dtos/sign_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mes_mobile_app/screens/location_inventory/location_inventory_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AlarmDatabase().database;
  setupTerminatedFCMListener();       // 종료 상태 클릭 처리
  setupForegroundFCMListener();       // 포그라운드 수신
  setupBackgroundFCMListener();       // 백그라운드 클릭

  runApp(const MyApp());
}

//레지파토리 초기화
AlarmRepository alarmRepository = new AlarmRepository();

//포그라운드 : 앱이 화면에 떠 있음
void setupForegroundFCMListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await alarmRepository.saveAlarmFromFCM(message);
  });
}

//백그라운드 :앱은 켜져 있으나 최소화 상태
void setupBackgroundFCMListener() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //await alarmRepository.saveAlarmFromFCM(message);

    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id');
    print("🔵 userId : ${userId}");

    if (userId == null || userId == ''){
      navigatorKey.currentState?.pushReplacementNamed(
          '/login'
      );
      return;
    }

    final data = message.data;
    final alarm = AlarmBasic.fromMap(data);

    if (alarm.signCd?.trim().isNotEmpty == true) {
      // 전자서명 알림: 화면 전환

      final signDto = SignDto.fromAlarm(alarm);

      navigatorKey.currentState?.pushReplacementNamed(
        '/sign',
        arguments: signDto,
      );
    } else {
      // 일반 알림: 확장/축소 토글
      navigatorKey.currentState?.pushReplacementNamed(
          '/alarms',
        arguments: alarm.appAlarmId);
    }
  });
}

//종료 :앱 완전히 꺼진 상태에서 푸시 클릭
void setupTerminatedFCMListener() async {
  final message = await FirebaseMessaging.instance.getInitialMessage();

   final storage = FlutterSecureStorage();
   final userId = await storage.read(key: 'user_id');
   print("🔵 userId : ${userId}");

   if (userId == null || userId == ''){
     navigatorKey.currentState?.pushReplacementNamed(
         '/login'
     );
     return;
   }

  final data = message?.data;

   if(data == null){
     navigatorKey.currentState?.pushReplacementNamed(
         '/home'
     );
     return;
   }

   final alarm = AlarmBasic.fromMap(data);

   if (alarm.signCd?.trim().isNotEmpty == true) {
     // 전자서명 알림: 화면 전환

     final signDto = SignDto.fromAlarm(alarm);

     navigatorKey.currentState?.pushReplacementNamed(
       '/sign',
       arguments: signDto,
     );

     return;
   } else {
     // 일반 알림: 확장/축소 토글
     navigatorKey.currentState?.pushReplacementNamed(
         '/alarms',
         arguments: alarm.appAlarmId);

     return;
   }


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, //pushReplacementNamed를쓸려면 필수다.
      title: 'MES App',
      initialRoute: '/splash', // 스플래시를 초기 라우트로 지정
      routes: {
        '/splash': (context) => const SplashScreen(), // 추가
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(), // ← 반드시 등록
        '/alarms': (context) => const AlarmListScreen(), // ← 알람 화면도 등록
        '/sign': (context) => const SignConfirmWrapper(), // ← 전자서명 화면도 등록, 매개값이 필요한 화면은 사전제 리턴해주는 파일을 하나더 만들어준다.
        '/putawayAndPicking': (context) => const PutawayAndPickingScreen(),
        '/locationInventory': (context) => const LocationInventoryScreen()
      },
    );
  }
}

