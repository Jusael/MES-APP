import 'dart:convert';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';
import 'package:mes_mobile_app/styles/format_decimal.dart';

class PutawayAndPickingController {
  static Future<Map<String, Object>> getBarcodeInfo(
    BuildContext context,
    String barCode,
  ) async {
    try {
      final userInfo = await ApiService.get(
        '/api/receipt/getbarcodeinfo',
        queryParams: {'BarCode': barCode},
      );

      final result = jsonDecode((userInfo.body));

      if (result['success'] != true) {
        throw Exception("일치하는 바코드가 없습니다.");
      }

      Map<String, Object> resultMap = Map<String, Object>();

      resultMap['message'] = "바코드 : ${barCode} 리딩에 성공하였습니다.";
      resultMap['icon'] = Icons.check_circle;
      resultMap['backGroundColor'] = Color.fromARGB(255, 225, 255, 220);
      resultMap['itemNm'] = result['itemNm'];
      resultMap['itemCd'] = result['itemCd'];
      resultMap['receiptLotNo'] = result['receiptLotNo'];
      resultMap['receiptValidDate'] = result['receiptValidDate'];
      resultMap['receiptPackQty'] = FormatDecimal.formatDecimal(
        result['receiptPackQty'],
      );
      resultMap['receiptPackRemainQty'] = FormatDecimal.formatDecimal(
        result['receiptPackRemainQty'],
      );
      resultMap['receiptStatus'] = result['receiptStatus'];

      return resultMap;
    } catch (e) {
      Map<String, Object> failMap = Map<String, Object>();

      failMap['message'] = e.toString();
      failMap['icon'] = Icons.warning;
      failMap['backGroundColor'] = Color.fromARGB(255, 184, 184, 184);
      failMap['itemNm'] = "";
      failMap['itemCd'] = "";
      failMap['receiptLotNo'] = "";
      failMap['receiptValidDate'] = "";
      failMap['receiptPackQty'] = "";
      failMap['receiptPackRemainQty'] = "";
      failMap['receiptStatus'] = "";

      return failMap;
    }
  }

  static Future<Map<String, Object>> getLocationInfo(
    BuildContext context,
    String barCode,
  ) async {
    try {
      final userInfo = await ApiService.get(
        '/api/common/getlocationbarcodeinfo',
        queryParams: {'BarCode': barCode},
      );

      final result = jsonDecode((userInfo.body));

      if (result['success'] != true) {
        throw Exception("일치하는 바코드가 없습니다.");
      }

      Map<String, Object> resultMap = Map<String, Object>();

      resultMap['message'] = "장소 바코드 : ${barCode} 리딩에 성공하였습니다.";
      resultMap['icon'] = Icons.check_circle;
      resultMap['backGroundColor'] = Color.fromARGB(255, 225, 255, 220);
      resultMap['wareHouseCd'] = result['wareHouseCd'];
      resultMap['wareHouseNm'] = result['wareHouseNm'];
      resultMap['zoneCd'] = result['zoneCd'];
      resultMap['zoneNm'] = result['zoneNm'];
      resultMap['cellCd'] = result['cellCd'];
      resultMap['cellNm'] = result['cellNm'];

      return resultMap;
    } catch (e) {
      Map<String, Object> failMap = Map<String, Object>();

      failMap['message'] = e.toString();
      failMap['icon'] = Icons.warning;
      failMap['backGroundColor'] = Color.fromARGB(255, 184, 184, 184);
      failMap['wareHouseCd'] = "";
      failMap['wareHouseNm'] = "";
      failMap['zoneCd'] = "";
      failMap['zoneNm'] = "";
      failMap['cellCd'] = "";
      failMap['cellNm'] = "";

      return failMap;
    }
  }

  static Future<Map<String, Object>> productPutAway(
    BuildContext context,
    String barCode,
    String location,
  ) async {
    try {
      final apiResult = await ApiService.post('/api/receipt/productputaway', {
        'BarCode': barCode,
        'Location': location,
      });

      final result = jsonDecode((apiResult.body));
      print("🔵 적치 응답 바디: '${apiResult.body}'");

      if (result["success"] != true)
        throw Exception("대상 : ${barCode}를  적치 실패 하였습니다.");

      Map<String, Object> resultMap = Map<String, Object>();

      resultMap['message'] = "대상 바코드 : ${barCode}를 적치 성공 하였습니다.";
      resultMap['icon'] = Icons.check_circle;
      resultMap['backGroundColor'] = Color.fromARGB(255, 225, 255, 220);

      return resultMap;
    } catch (e) {
      Map<String, Object> failMap = Map<String, Object>();

      failMap['message'] = e.toString();
      failMap['icon'] = Icons.warning;
      failMap['backGroundColor'] = Color.fromARGB(255, 184, 184, 184);

      return failMap;
    }
  }

  static Future<Map<String, Object>> productPicking(
    BuildContext context,
    String barCode,
  ) async {
    try {
      final apiResult = await ApiService.post('/api/receipt/productpicking', {
        'barCode': barCode,
      });

      final result = jsonDecode((apiResult.body));
      print("🔵 피킹 응답 바디: '${apiResult.body}'");

      if (result["success"] != true)
        throw Exception("대상 : ${barCode}를 피킹에 실패하였습니다.");

      Map<String, Object> resultMap = Map<String, Object>();

      resultMap['message'] = "대상 바코드 : ${barCode} 피킹에 성공하였습니다.";
      resultMap['icon'] = Icons.check_circle;
      resultMap['backGroundColor'] = Color.fromARGB(255, 225, 255, 220);

      return resultMap;
    } catch (e) {
      Map<String, Object> failMap = Map<String, Object>();

      failMap['message'] = e.toString();
      failMap['icon'] = Icons.warning;
      failMap['backGroundColor'] = Color.fromARGB(255, 184, 184, 184);

      return failMap;
    }
  }
}
