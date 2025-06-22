import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';

  class BiometricAuthService {
   final _auth = LocalAuthentication();

  // 생체인증 사용 가능한지 확인
  Future<bool> isBiometricAvailable() async {
    return await _auth.canCheckBiometrics;
  }

  // 사용 가능한 생체인증 종류 확인
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  // 생체인증 실행
   Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: '지문 또는 얼굴로 인증해주세요.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('🔴 인증 오류: $e');
      return false;
    }
  }

   static Future<bool> checkBionic(BuildContext context) async {
     //사용자 지문체크
     final BiometricAuthService _biometricAuth = BiometricAuthService();
     bool canUseBiometric = await _biometricAuth.isBiometricAvailable();

     //생체 인증 가능 기기 여부 체크
     if (!canUseBiometric) {
       DialogHelper.showErrorDialog(context, '생체 인증을 지원하지 않는 기기입니다.');
       return false;
     }

     bool isAuthenticated = await _biometricAuth.authenticate();
     if (isAuthenticated) {
       return true;
     } else {
       DialogHelper.showErrorDialog(context, '생체인증에 실패했습니다.');
       return false;
     }
   }

}