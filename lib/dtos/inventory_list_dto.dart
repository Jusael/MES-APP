import 'package:mes_mobile_app/styles/format_decimal.dart';

class InventoryItemDto {
  final String itemCd;
  final String itemNm;
  final String lotNo;
  final String packBarCode;
  final String receiptQty;
  final String remainQty;

  InventoryItemDto({
    required this.itemCd,
    required this.itemNm,
    required this.lotNo,
    required this.packBarCode,
    required this.receiptQty,
    required this.remainQty,
  });

  // JSON -> DTO (서버에서 받을 때)
  factory InventoryItemDto.fromJson(Map<String, dynamic> json) {
    return InventoryItemDto(
      itemCd: json['itemCd'] ?? '',
      itemNm: json['itemNm'] ?? '',
      lotNo: json['lotNo'] ?? '',
      packBarCode: json['packBarCode'] ?? '',
      receiptQty: FormatDecimal.formatDecimal(
        (json['receiptQty'] ?? '0').toString(),
      ),
      remainQty: FormatDecimal.formatDecimal(
        (json['remainQty'] ?? '0').toString(),
      ),
    );
  }

  // DTO -> JSON (서버로 보낼 때)
  Map<String, dynamic> toJson() {
    return {
      'itemCd': itemCd,
      'itemNm': itemNm,
      'lotNo': lotNo,
      'packBarCode': packBarCode,
      'receiptQty': receiptQty,
      'remainQty': remainQty,
    };
  }
}
