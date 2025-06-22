import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';

class ApiExceptionHandler {
  static String handleError(dynamic e) {
    String message = '요청을 처리하는 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';

    if (e is SocketException) {
      message = '인터넷 연결이 원활하지 않습니다.\n네트워크 상태를 확인해주세요.';
    } else if (e is TimeoutException) {
      message = '서버 응답 시간이 초과되었습니다.';
    } else if (e is FormatException) {
      message = '서버 응답 형식이 잘못되었습니다.';
    } else {
      message = e.toString(); // 디버깅용
    }

    return message;
  }
}