import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/services/biometric_auth_service.dart';
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';
import 'package:mes_mobile_app/screens/sign/sign_confirm_controller.dart';
import 'package:mes_mobile_app/dtos/sign_dto.dart';
import 'package:mes_mobile_app/styles/text_styles.dart';
import 'package:mes_mobile_app/screens/alarm/alarm_list_control.dart';
import 'package:mes_mobile_app/database/alarm_database.dart';

final AlarmController alarmController = AlarmController();

class SignatureConfirmScreen extends StatefulWidget {
  final SignDto signDto;


  const SignatureConfirmScreen({super.key, required this.signDto});

  @override
  State<SignatureConfirmScreen> createState() => _SignatureConfirmScreenState();
}

class _SignatureConfirmScreenState extends State<SignatureConfirmScreen> {
  bool _isLoading = true;
  bool _isSignIngYn = false;
  Map<String, dynamic>? _mapSearchSignResult;

  @override
  void initState() {
    print('📘 SignatureConfirmScreen initState 호출됨');
    super.initState();
    signSearch(context);
  }

  Future<void> signSearch(BuildContext context) async {
    try {
      final searchSignResult = await signConfirm.searchSignInfo(
        context,
        widget.signDto.signCd,
        widget.signDto.signId,
      );

      final stopwatch = Stopwatch()..start();
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 500) {
        await Future.delayed(Duration(milliseconds: 500 - elapsed));
      }

      //setState가 바뀌면 빌더를 다시부르고 UI 가 갱신된다
      setState(() {
        _isSignIngYn =
            (searchSignResult['signTime'] != null &&
            searchSignResult['signTime'] != "");
        _mapSearchSignResult = searchSignResult;
        _isLoading = false;
      });

      //정상 조회까지 했다면, 서버 DB, 앱 DB 읽음처리
      await this.markAsRead();
      await alarmController.postUpdateAlarmStatus(context, widget.signDto.appAlarmId.toString(), 'READ');
      
    } catch (e) {
      Navigator.pop(context);
      DialogHelper.showErrorDialog(
        context,
        '전자서명 조회 실패: ${ApiExceptionHandler.handleError(e)}',
      );

      setState(() => _isLoading = false); // 오류 발생해도 로딩 해제
    }
  }

  // 알림 읽음 처리
  Future<void> markAsRead() async {

    final db = AlarmDatabase();
      await db.markAsRead(widget.signDto.id);
  }

  Future<void> signFunc(BuildContext context) async {
    if (_isSignIngYn) return;

    try {
      // 1. 지문 인증 먼저
      final isBiometricOk = await BiometricAuthService.checkBionic(context);
      if (!isBiometricOk) return;

      // 2. 사용자 ID 가져오기
      final storage = FlutterSecureStorage();
      final userId = (await storage.read(key: 'user_id')) ?? '';

      // 3. 서명 대상자 확인
      final isValidUser = await signConfirm.checkSignUser(
        context,
        userId,
        widget.signDto.signCd,
        widget.signDto.signId,
      );
      if (!isValidUser) return;

      // 4. 전자서명 시도
      final isSuccess = await signConfirm.signIng(
        context,
        userId,
        widget.signDto.signCd,
        widget.signDto.signId,
        widget.signDto.appAlarmId.toString(),
        widget.signDto.mesAlarmId.toString(),
        widget.signDto.key1,
        widget.signDto.key2,
        widget.signDto.key3,
        widget.signDto.key4,
        widget.signDto.key5,
      );

      // 5. 성공/실패 로티 애니메이션 띄우기
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Center(
            child: Lottie.asset(
              isSuccess ? 'assets/Sucess.json' : 'assets/Error.json',
              width: 150,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                });
              },
            ),
          );
        },
      );

      // 6. 성공 시 서명 재조회 및 안내
      if (isSuccess) {
        await signSearch(context);
        DialogHelper.showSuccessDialog(
          context,
          '전자서명에 성공하였습니다.\n결과 반영까지 시간이 소요될 수 있습니다.',
        );
      } else {
        DialogHelper.showErrorDialog(context, '전자서명에 실패하였습니다.');
      }

    } catch (e) {
      // 오류 시 실패 로티 띄우기
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Center(
            child: Lottie.asset(
              'assets/Error.json',
              width: 150,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                });
              },
            ),
          );
        },
      );

      DialogHelper.showErrorDialog(
        context,
        '전자서명 중 오류 발생: ${ApiExceptionHandler.handleError(e)}',
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final sign = widget.signDto;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, '/alarms',arguments: widget.signDto.appAlarmId);
          return false;
        },
        child: Scaffold(
      appBar: AppBar(
        title: const Text("전자서명 확인", style: AppTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 94, 176, 255),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 항상 알람리스트로 이동
            Navigator.pushReplacementNamed(context, '/alarms',arguments: widget.signDto.appAlarmId);
          },
        ),

      ),
      body: _isLoading  // 🔹 여기가 핵심!
          ? const Center(
        child: CircularProgressIndicator(), // 또는 Lottie.asset('assets/Loding.json')
      )
          :  Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSignInfoCard(),
            _buildAlarmInfoCard(sign),
            const SizedBox(height: 14),
            _buildWarningBox(),
            const Spacer(),
            _isSignIngYn ? const SizedBox()
                :Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                        icon: const Icon(Icons.key, color: Colors.blue),
                        label: const Text(
                          "전자서명 서명하기",
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          minimumSize: const Size(50, 50),
                        ),
                        onPressed
                            : () => signFunc(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildSignInfoCard() {
    if (_mapSearchSignResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Uint8List? imageByte;
    final imageBase64 = _mapSearchSignResult!['signImage'];

    if (imageBase64 != null && imageBase64.toString().isNotEmpty) {
      try {
        imageByte = base64Decode(imageBase64.toString());
      } catch (e) {
        print("❌ base64 decode failed: $e");
      }
    }

    return Stack(
      children: [
        Card(
          color: Color.fromARGB(255, 94, 176, 255),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        (imageByte != null && imageByte.toString().isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageByte,
                              fit: BoxFit.contain,
                              height: 120,
                            ),
                          )
                        : const Text(
                            '진행 정보 없음',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.description, size: 22, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      "서명 진행 정보",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '역할 : ${_mapSearchSignResult!['signDetailNm'] ?? '매칭 정보 없음'}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                Text(
                  '서명 대상자 : ${_mapSearchSignResult!['signDetailUserNm'] ?? '매칭 정보 없음'}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                Text(
                  '서명 대상자 사번 : ${_mapSearchSignResult!['signDetailUserId'] ?? '매칭 정보 없음'}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                const Divider(thickness: 1.5),
                Text(
                  '서명자 사번 : ${_mapSearchSignResult!['signSignEmpCd'] ?? ''}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                Text(
                  '서명자 : ${_mapSearchSignResult!['signSignEmpNm'] ?? ''}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                Text(
                  '서명 시각 : ${_mapSearchSignResult!['signTime'] ?? ''}',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        if (_isSignIngYn)
          Positioned(
            top: -5,
            right: 2,
            child: Image.asset('assets/승인완료.png', width: 70),
          ),
      ],
    );
  }

  Widget _buildAlarmInfoCard(SignDto sign) {
    return Card(
      color: const Color.fromARGB(255, 239, 239, 239),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, size: 22, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  sign.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "서명 대상 정보",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (sign.content1 != null && sign.content1.trim().isNotEmpty)
              Text(sign.content1, style: AppTextStyles.body),
            if (sign.content2 != null && sign.content2.trim().isNotEmpty)
              Text(sign.content2, style: AppTextStyles.body),
            if (sign.content3 != null && sign.content3.trim().isNotEmpty)
              Text(sign.content3, style: AppTextStyles.body),
            if (sign.content4 != null && sign.content4.trim().isNotEmpty)
              Text(sign.content4, style: AppTextStyles.body),
            if (sign.content5 != null && sign.content5.trim().isNotEmpty)
              Text(sign.content5, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _isSignIngYn
            ? "전자서명이 완료 되었습니다."
            : "⚠️ 전자서명은 인증 후 취소할 수 없습니다.\n정확한 정보를 확인하고 진행하세요.",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
