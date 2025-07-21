import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mes_mobile_app/services/biometric_auth_service.dart';

class LoginController {
  //1.1 Flutter에서 로그인 정보를 API로 POST 요청
  //   1.2 API는 DB에서 다음 조건을 검사:
  //      - 사번(ID) 일치 여부
  //      - 금일 날짜 기준으로 유효기간 내에 있는지
  Future<int> getUserInfo(
    BuildContext context,
    String userId,
    String password,
  ) async {
    try {
      final userInfo = await ApiService.post('/api/login/post-user-info', {
        'userId': userId,
        'passWord': password,
      });
      print("🔵 상태코드: ${userInfo.statusCode}");
      print("🔵 응답 바디: '${userInfo.body}'");
      final result = jsonDecode((userInfo.body));
      if (result['succes'] != true) {
        throw Exception("사번 또는 패스워드를 확인해 주세요.\n정보가 정확하다면, 계정 유효기간을 확인해주세요.");
      }
      return result['level'];
    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '로그인 실패: ${ApiExceptionHandler.handleError(e)}',
      );
      return -1;
    }
  }

  //NOTE : FCM 토큰을 DB에 저장 로그인할때마다 진행
  Future<bool> postFcmToken(BuildContext context, String userId) async {
    try {
      String? fcmToken = await getFcmToken();

      if (fcmToken == null)
        throw Exception("FCM 토큰을 발급받지 못했습니다.\n잠시 후 다시 시도해주세요.");

      final userInfo = await ApiService.post('/api/login/post-fcm', {
        'userId': userId,
        'fcmToken': fcmToken,
      });

      final result = jsonDecode((userInfo.body));
      print("🔵 상태코드: ${userInfo.statusCode}");
      print("🔵 응답 바디: '${userInfo.body}'");
      if (result['success'] != true)
        throw Exception("FCM 토큰을 발급받지 못했습니다.\n잠시 후 다시 시도해주세요.");

      //앱 스토리지에 저장
      final storage = FlutterSecureStorage();
      await storage.write(key: 'fcm', value: fcmToken);

      return true;
    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '로그인 실패: ${ApiExceptionHandler.handleError(e)}',
      );
      return false;
    }
  }

  Future<bool> postJwtToken(BuildContext context, String userId) async {
    try {
      final userInfo = await ApiService.post('/api/login/post-jwt', {
        'userId': userId,
      });
      print("🔵 상태코드: ${userInfo.statusCode}");
      print("🔵 응답 바디: '${userInfo.body}'");
      final result = jsonDecode((userInfo.body));
      final expireDays = result['expiresInDays']; // dynamic 타입
      final expireTime = DateTime.now().add(Duration(days: expireDays));

      if (result['success'] != true)
        throw Exception("접속 인증 토큰을 발급받지 못했습니다.\n계정 유효기간을 확인 해주세요.");

      String jwtToken = result['token'];

      //앱 스토리지에 저장
      final storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: jwtToken);
      await storage.write(
        key: 'jwt_expire',
        value: expireTime.toIso8601String(),
      );

      print("🔵 jwt토큰 : ${jwtToken}");

      return true;
    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '로그인 실패: ${ApiExceptionHandler.handleError(e)}',
      );
      return false;
    }
  }

  Future<String?> getFcmToken() async {
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    print("FCM 토큰: $token");
    return token;
  }

  //계정 END DATE 유효성 검사
  Future<bool> checkExpire(BuildContext context) async {
    final storage = FlutterSecureStorage();
    try {
      String? expireStr = await storage.read(key: 'jwt_expire');

      if (expireStr != null) {
        DateTime expireTime = DateTime.parse(expireStr);

        if (DateTime.now().isBefore(expireTime)) {
          return true;
        } else {
          await storage.delete(key: 'jwt');
          await storage.delete(key: 'jwt_expire');
          throw Exception("계정의 유효기간이 만료되었습니다.");
        }
      }

      return false;

    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '로그인 실패: ${ApiExceptionHandler.handleError(e)}',
      );
      return false;
    }
  }


}
