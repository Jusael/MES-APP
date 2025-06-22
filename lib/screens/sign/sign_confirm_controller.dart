import 'dart:convert';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';

class signConfirm {

  //계정이 해당 알람에 대한 전자서명권한이 있는지
 static Future<bool> checkSignUser(BuildContext context, String userId, String signCd, String signId) async {
    try{
      final userInfo = await ApiService.get(
        '/api/Sign/getusersigninfo',
        queryParams: {
          'UserId': userId,
          'SignCd' : signCd,
          'SignId': signId,
        },
      );

      print("🔵 상태코드: ${userInfo.statusCode}");
      print("🔵 응답 바디: '${userInfo.body}'");

      final result = jsonDecode((userInfo.body));

      if (result['success'] != true) {
        throw Exception("전자서명 권한이 없습니다.");
      }

      return true;

    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '${ApiExceptionHandler.handleError(e)}',
      );
      return false;
    }
  }

  //전자서명 진행 함수
  static Future<bool> signIng(BuildContext context
      , String userId
      , String signCd
      , String signId
      , String AppAlarmId
      , String MesAlarmId
      , String Key1
      , String Key2
      , String Key3
      , String Key4
      , String Key5)async {
    try{
      final signIngResult = await ApiService.post('/api/Sign/postsigning', {
        'UserId':userId,
        'SignCd':signCd,
        'SignId':signId,
        'AppAlarmId':AppAlarmId,
        'MesAlarmId':MesAlarmId,
        'Key1':Key1,
        'Key2':Key2,
        'Key3':Key3,
        'Key4':Key4,
        'Key5':Key5,
      });

      final result = jsonDecode((signIngResult.body));
      print("🔵 서명 응답 바디: '${signIngResult.body}'");

      if(result["success"]!= true)
        throw Exception("전자서명에 실패하였습니다.");

      return true;

    }catch(e){
      DialogHelper.showErrorDialog(
        context,
        '${ApiExceptionHandler.handleError(e)}',);
      return false;
    }

  }

 //이미 전자서명을 했는지 전자서명 화면 최초 조회
 static Future<Map<String, dynamic>> searchSignInfo(BuildContext context, String signCd, String signId) async {
   try{
     final signInfo = await ApiService.get(
       '/api/Sign/getsearchSignInfo',
       queryParams: {
         'SignCd' : signCd,
         'SignId': signId,
       },
     );

     print("🔵 상태코드: ${signInfo.statusCode}");
     print("🔵 응답 바디: '${signInfo.body}'");

     final result = jsonDecode((signInfo.body));

     if (result['success'] != true)
       throw Exception("전자서명 조회에 실패하였습니다.");


     return result;

   } catch (e) {
     DialogHelper.showErrorDialog(
       context,
       '${ApiExceptionHandler.handleError(e)}',
     );
     return {
       'success': false,
       'message': e.toString(),
     };
   }
 }
}


