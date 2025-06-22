import 'dart:convert';
import 'package:mes_mobile_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mes_mobile_app/dtos/inventory_list_dto.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/helpers/ApiExceptionHandler.dart';
import 'package:mes_mobile_app/styles/format_decimal.dart';

class InventoryControllerController {
  static Future<Map<String, Object>> getLocationInfo(
    BuildContext context,
    String barCode,
  ) async {
    try {
      final apiInfo = await ApiService.get(
        '/api/common/getlocationbarcodeinfo',
        queryParams: {'BarCode': barCode},
      );

      final result = jsonDecode((apiInfo.body));

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
  static Future<List<InventoryItemDto>> getInventoryList(
      BuildContext context,
      String barCode,
      ) async {
    try {
      final apiInfo = await ApiService.get(
        '/api/receipt/getinventorylist',
        queryParams: {'BarCode': barCode},
      );

      // 이미 String -> jsonDecode 1회만 수행
      final result = jsonDecode(apiInfo.body);

      if (result is! Map<String, dynamic>) {
        throw Exception("API 응답형식 오류 (Map 아님)");
      }

      if (result['success'] != true) {
        throw Exception("적치 재고 조회중 오류가 발생하였습니다.");
      }

      // 핵심: 리스트 파싱시 항상 null-safe 처리
      final List<dynamic> dataList = (result['result'] ?? []) as List<dynamic>;

      // DTO 변환
      final List<InventoryItemDto> list = dataList
          .map(
            (item) => InventoryItemDto.fromJson(item as Map<String, dynamic>),
      )
          .toList();

      return list;
    } catch (e) {
      print(e);
      throw Exception("적치 재고 조회중 오류가 발생하였습니다.");
    }
  }
}
