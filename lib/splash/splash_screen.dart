import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mes_mobile_app/main.dart';
import 'package:mes_mobile_app/screens/login/login_controller.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mes_mobile_app/dtos/sign_dto.dart';
import 'package:mes_mobile_app/dtos/alarm_dto.dart';
import 'package:mes_mobile_app/screens/sign/sign_confirm_screen.dart';
import 'package:mes_mobile_app/screens/alarm/alarm_list_screen.dart';
import 'package:mes_mobile_app/database/alarm_database.dart';
import 'package:mes_mobile_app/database/alarm_repository.dart';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
//NOTE :
//스플래쉬 화면 사용이유
//1. 종료 일때, 이미 접속 정보가 있는경우 Home 없는경우 Ligin
//2. 종료 일때, 사용자 정보가 있고, 알람을 클릭한경우
//2.1 (전자서명 알림 -> 전자서명화면)
//2.2 (일반 알림     -> 알림 리스트)

//NOTE:
//종료 상태의 앱은 알람을 받아도 바로 로컬에 저장하지 못한다.
//앱이 실행상태인 경우에만 가능하며, 종료인경우 알람이 10개 일때,
//클릭한 한 알람만 추적이 가능하다.
// 종료 일경우 -> 핸드폰 알람 클릭 -> 스플래쉬 화면 -> 10개의 알람정보를 API에서 Get
// -> Get한 10개의 알람을 database에 insert

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

bool isTokenExpired(String token) {
  return JwtDecoder.isExpired(token);
}

Future<bool> checkAutoLogin(BuildContext context) async {
  final storage = FlutterSecureStorage();
  final userId = await storage.read(key: 'user_id');
  print("🔵 userId : ${userId}");

  if (userId == null || userId == '') return false;

  //NOTE:
  //FCM토큰을 업데이트한다.
  //FCM 토큰은 앱에서 발생 -> DB에 저장 -> 성공 -> 앱 스토리지에 저장
  final LoginController loginController = LoginController();
  if (!await loginController.postFcmToken(context, userId)) return false;

  return true;
}

Future<void> insertNotExistsMessage(BuildContext context) async {
  final db = await AlarmDatabase().database;

  final storage = FlutterSecureStorage();
  final String? userId = await storage.read(key: 'user_id');
  print("🔵 userId : ${userId}");

  final response = await ApiService.get(
    '/api/alarm/get-incoming-alarm-but-unread',
    queryParams: {'UserId': userId ?? ''},
  );

  // 3. 받아온 알람들을 저장
  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes);

    final List<dynamic> alarmList = jsonDecode(decodedBody);

    final alarmRepository = AlarmRepository();
    for (final alarmJson in alarmList) {
      final alarm = AlarmBasic.fromMap(alarmJson);
      await alarmRepository.insertAlarmIfNotExists(alarm);
    }
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🟡 initState 진입');

    Future.delayed(const Duration(seconds: 1), () async {
      await Firebase.initializeApp();
      final message = await FirebaseMessaging.instance.getInitialMessage();
      final Map<String, dynamic>? messageData = message?.data;

      final autoLogin = await checkAutoLogin(context); // 이미 로그인된 유저인지
      //로그인이 없다면 무조건 Login 화면


      print('✔✔ USER ID 없음');
      if (!autoLogin) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt');

      if (token == null || isTokenExpired(token)) {
        // 토큰 없음 or 만료 → 로그인으로 보내기
        Navigator.pushReplacementNamed(context, '/login');
      }

      print('✔✔ 누락된 알람 동기화 로직 전');
      if (autoLogin) await insertNotExistsMessage(context);

      if (messageData == null) {
        Navigator.pushReplacementNamed(context, '/home');

        return;
      } else if (message != null &&
          messageData['signCd'] != null &&
          !messageData['signCd'].isEmpty) {
        print('📨 종료 상태 메시지: ${message?.data}');


        final alarmDto = AlarmBasic.fromMap(messageData);
        final signDto = SignDto.fromAlarm(alarmDto);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignatureConfirmScreen(signDto: signDto),
          ),
        );

        return;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AlarmListScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/assetslogo.png')),
    );
  }
}
