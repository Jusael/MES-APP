import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_controller.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/screens/home/home_screen.dart';
import 'package:mes_mobile_app/services/biometric_auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//region - 로그인 및 토큰 처리 플로우 -
///
///
/// 1. 사용자 로그인 시도
///   1.1 Flutter에서 로그인 정보를 API로 POST 요청
///   1.2 API는 DB에서 다음 조건을 검사:
///       - 사번(ID) 일치 여부
///       - 금일 날짜 기준으로 유효기간 내에 있는지
///   1.3 조건이 만족되면 로그인 성공 응답(OK)을 반환
///
/// 2. 로그인 요청 시, 반드시 FCM 토큰도 함께 전송
///   2.1 API는 전달받은 FCM 토큰을 사용자 사번에 매핑하여 DB에 저장
///   2.2 저장 성공 시 OK 응답
///
/// 3. JWT 토큰 처리
///   3.1 JWT 토큰이 FlutterSecureStorage에 존재하는 경우
///       3.1.1 JWT의 유효기간(exp)이 만료되었는지 검사
///           - 만료된 경우: 로그아웃 처리 후 로그인 화면으로 이동
///           - 유효한 경우: 앱 내에 저장된 토큰으로 계속 사용
///       3.1.2 이후 홈(메인) 화면으로 이동
///
///   3.2 JWT 토큰이 존재하지 않는 경우
///       3.2.1 로그인 성공 직후 API에 JWT 토큰 발급 요청
///       3.2.2 API는 JWT를 생성하여 클라이언트에 응답
///       3.2.3 Flutter는 해당 토큰을 SecureStorage에 저장
///       3.2.4 저장 완료 후 홈(메인) 화면으로 이동
//endregion

// 로그인 컨트롤러 전역 선언
final LoginController loginController = LoginController();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int? userLevel;
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final storage = FlutterSecureStorage();

  Future<void> loginAccess(
    BuildContext context,
    String userId,
    String password,
  ) async {
    //NOTE:
    //사번과 권환 레벨을 조회한다.
    // 사번이 없거나 오류 발생시 -1로 리턴
    // 일반 사용자 1 admin 10
    final level = await loginController.getUserInfo(context, userId, password);

    if (level == -1) return;

    setState(() {
      userLevel = level;
    });

    //NOTE:
    //FCM토큰을 업데이트한다.
    //FCM 토큰은 앱에서 발생 -> DB에 저장 -> 성공 -> 앱 스토리지에 저장
    if (!await loginController.postFcmToken(context, userId)) return;

    final storage = FlutterSecureStorage();

    // 저장된 JWT토큰 불러오기
    String? token = await storage.read(key: 'jwt');
    if (token != null) {
      //토큰 유효일자 체크
      if(! await loginController.checkExpire(context)) return;
    }else
      {
        if(!await loginController.postJwtToken(context,userId)) return;

      }

    if(! await checkBionic()) return;

    await storage.write(key: 'user_id', value: userId);

    Navigator.pushReplacementNamed(context, '/home');
  }
  
    //생체 정보 체크
    Future<bool> checkBionic() async{
        //사용자 지문체크
        final BiometricAuthService _biometricAuth = BiometricAuthService();
        bool canUseBiometric = await _biometricAuth.isBiometricAvailable();

        //생체 인증 가능 기기 여부 체크
        if (!canUseBiometric) {
          DialogHelper.showErrorDialog(
            context,
            '이 기기에서 생체인증을 사용할 수 없습니다.',
          );
          return false;
        }

        bool isAuthenticated = await _biometricAuth.authenticate();
        if (isAuthenticated) {
          return true;
        } else {
          DialogHelper.showErrorDialog(
            context,
            '생체인증에 실패했습니다.',
          );
          return false;
        }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/assetslogo.png', width: 300, height: 300),
              const SizedBox(height: 30),

              SizedBox(
                width: 250,
                child: TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: 250,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: 250,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '전화번호',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    await loginAccess(
                      context,
                      userIdController.text,
                      passwordController.text,
                    );
                    final fcm = FirebaseMessaging.instance;
                    final token = await fcm.getToken();
                    print("FCM 토큰: $token");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance(); //SharedPreferences (일반 저장소)
                    await prefs.remove('jwt');
                    await prefs.remove('fcm');
                    await storage.delete(key: 'jwt'); // FlutterSecureStorage (보안 저장소)
                    await storage.delete(key: 'fcm');
                    DialogHelper.showErrorDialog(context, "로그아웃 완료");
                  },
                  child: const Text("로그아웃"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
