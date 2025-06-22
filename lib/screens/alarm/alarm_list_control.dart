import 'package:mes_mobile_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';

class AlarmController {


  //알람의 읽음 및 삭제여부를 DB에 Post한다.
  //성공유무가 중하지 않아 단순 Post
  Future<void> postUpdateAlarmStatus(BuildContext context,String appAlarmId, String alarmStatus) async {
    try {

      final userInfo = await ApiService.post('/api/Alarm/postalarmstatuscontroll', {
        'AppAlarmId': appAlarmId,
        'AlarmStatus': alarmStatus,
      });

    } catch (e) {
      DialogHelper.showErrorDialog(
        context,
        '로그인 실패: ${ApiExceptionHandler.handleError(e)}',
      );
    }
  }


}
