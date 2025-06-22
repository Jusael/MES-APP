import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mes_mobile_app/common_widgets/barcode_scanner.dart';
import 'package:mes_mobile_app/common_widgets/barcode.dart';
import 'package:mes_mobile_app/screens/location_inventory/location_inventory_controller.dart';
import 'package:mes_mobile_app/dtos/inventory_list_dto.dart';
import 'package:mes_mobile_app/styles/text_styles.dart';


class LocationInventoryScreen extends StatefulWidget {
  const LocationInventoryScreen({super.key});

  @override
  State<LocationInventoryScreen> createState() =>
      _LocationInventoryScreenState();
}

class _LocationInventoryScreenState extends State<LocationInventoryScreen> {
  Color _backGroundColor = Colors.white;
  IconData _resultIcon = Icons.help_outline;
  String _message = "대상 또는 위치 바코드를 스캔해주세요";

  String _locationBarcode = "";

  String _warehouseCd = "";
  String _warehouseNm = "";
  String _zoneCd = "";
  String _zoneNm = "";
  String _cellCd = "";
  String _cellNm = "";

  // 샘플 조회 결과
  List<InventoryItemDto>  inventoryList = [];

  Set<String> _expandedKeys = {};

  // 장소 바코드 스캔 예제 (실제로는 바코드 스캐너 호출해야 함)
  Future<void> scanLocationProduct(void Function(String) setter) async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => const BarcodeScannerBottomSheet(),
      );

      if (result == null) throw Exception("바코드를 인식하지 못했습니다.\n다시 시도해주세요.");

      final resultMap = await InventoryControllerController.getLocationInfo(
        context,
        result,
      );

      inventoryList = await InventoryControllerController.getInventoryList(context, result);

      final groupedItemList = <String, List<InventoryItemDto>>{};
      for (var item in inventoryList) {
        String groupKey = '${item.itemCd}_${item.lotNo}';
        groupedItemList.putIfAbsent(groupKey, () => []).add(item);
      }

      setState(() {
        _backGroundColor = resultMap['backGroundColor'] as Color;
        _resultIcon = resultMap['icon'] as IconData;
        _message = resultMap['message'].toString();

        _locationBarcode = result;
        _warehouseCd = resultMap['wareHouseCd'].toString() ?? "";
        _warehouseNm = resultMap['wareHouseNm'].toString() ?? "";
        _zoneCd = resultMap['zoneCd'].toString() ?? "";
        _zoneNm = resultMap['zoneNm'].toString() ?? "";
        _cellCd = resultMap['cellCd'].toString() ?? "";
        _cellNm = resultMap['cellNm'].toString() ?? "";

        _expandedKeys = groupedItemList.keys.toSet();
      });
    } catch (e) {
      setState(() {
        _backGroundColor = Colors.grey;
        _resultIcon = Icons.error;
        _message = e.toString();
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    final groupedItemList = <String, List<InventoryItemDto>>{};
    for (var item in inventoryList) {
      String groupKey = '${item.itemCd}_${item.lotNo}';
      groupedItemList.putIfAbsent(groupKey, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("장소재고조회", style: AppTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 94, 176, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 7),
            _resultBar(_backGroundColor, _resultIcon, _message),
            const SizedBox(height: 7),

            const SizedBox(height: 10),
            _band(Icons.inventory, "적치 내역"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: groupedItemList.entries.expand((entry) {
                  String groupKey = entry.key;
                  var firstItem = entry.value.first;

                  return [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_expandedKeys.contains(groupKey)) {
                            _expandedKeys.remove(groupKey);
                          } else {
                            _expandedKeys.add(groupKey);
                          }
                        });
                      },
                      child: _detailBand('품목: ${firstItem.itemNm} [${firstItem.itemCd}] / 제조번호: ${firstItem.lotNo}'),
                    ),
                    if (_expandedKeys.contains(groupKey))
                      ...entry.value.map(
                            (item) => Container(
                          padding: const EdgeInsets.only(left: 30, right: 12, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text("${item.packBarCode}")),
                              Expanded(flex: 1, child: Text("입고량: ${item.receiptQty}")),
                              Expanded(flex: 1, child: Text("재고량: ${item.remainQty}")),
                            ],
                          ),
                        ),
                      ),
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _band(Icons.qr_code, "장소정보"),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                //함수를 호출 함수의 호출후 콜백으로 값을 받아오는 문법
                _buildBarcodeBox(
                  _locationBarcode,
                  () => scanLocationProduct((v) => _locationBarcode = v),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("창고코드", _warehouseCd),
                      _infoRow("창고명", _warehouseNm),
                      _infoRow("구역코드", _zoneCd),
                      _infoRow("구역명", _zoneNm),
                      _infoRow("셀코드", _cellCd),
                      _infoRow("셀", _cellNm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 기존 바코드 타일 그대로 재활용
  Widget _buildBarcodeBox(String? barcode, VoidCallback FncOnTap) {
    return InkWell(
      onTap: FncOnTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: (barcode?.isEmpty ?? true) ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: (barcode?.isEmpty ?? true)
              ? const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey)
              : Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: BarcodeBox(barcode: barcode, onTap: FncOnTap),
                ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text("$label:")),
          Expanded(
            child: AutoSizeText(
              value,
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _band(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      //margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 94, 176, 255),

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _detailBand(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      //margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 213, 212, 212),

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _resultBar(_backGroundColor, icon, message) {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: _backGroundColor,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 101, 99, 99),
            ),
              overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
