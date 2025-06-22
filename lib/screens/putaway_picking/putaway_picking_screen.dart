import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mes_mobile_app/common_widgets/barcode_scanner.dart';
import 'package:mes_mobile_app/common_widgets/barcode.dart';
import 'package:mes_mobile_app/styles/text_styles.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:mes_mobile_app/screens/putaway_picking/putaway_picking_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PutawayAndPickingScreen extends StatefulWidget {
  const PutawayAndPickingScreen({super.key});

  @override
  State<PutawayAndPickingScreen> createState() =>
      _PutawayAndPickingScreenState();
}

class _PutawayAndPickingScreenState extends State<PutawayAndPickingScreen> {
  Color _backGroundColor = Colors.white;
  IconData _resultIcon = Icons.help_outline;
  String _message = "대상 또는 위치 바코드를 스캔해주세요";

  String _productBarcode = "";
  String _locationBarcode = "";

  String _itemNm = "";
  String _itemCd = "";
  String _receiptLotNo = "";
  String _receiptValidDate = "";
  String _receiptPackQty = "";
  String _receiptPackRemainQty = "";
  String _receiptStatus = "";

  String _warehouseCd = "";
  String _warehouseNm = "";
  String _zoneCd = "";
  String _zoneNm = "";
  String _cellCd = "";
  String _cellNm = "";

  bool _scanProductResult = false;
  bool _scanLocationtResult = false;

  Future<void> scanProduct(void Function(String) setter) async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => const BarcodeScannerBottomSheet(),
      );

      if (result == null) throw Exception("바코드를 인식하지 못했습니다.\n다시 시도해주세요.");

      final resultMap = await PutawayAndPickingController.getBarcodeInfo(
        context,
        result,
      );

      setState(() {
        _backGroundColor = resultMap['backGroundColor'] as Color;
        _productBarcode = result;
        _resultIcon = resultMap['icon'] as IconData;
        _message = resultMap['message'].toString();
        _itemNm = resultMap['itemNm'].toString() ?? "";
        _itemCd = resultMap['itemCd'].toString() ?? "";
        _receiptLotNo = resultMap['receiptLotNo'].toString() ?? "";
        _receiptValidDate = resultMap['receiptValidDate'].toString() ?? "";
        _receiptPackQty = resultMap['receiptPackQty'].toString() ?? "";
        _receiptPackRemainQty =
            resultMap['receiptPackRemainQty'].toString() ?? "";
        _receiptStatus = resultMap['receiptStatus'].toString() ?? "";
        _scanProductResult = true;
      });
    } catch (e) {
      setState(() {
        _backGroundColor = Colors.grey;
        _resultIcon = Icons.error;
        _message = e.toString();
        _scanProductResult = false;
      });
    }
  }

  Future<void> scanLocationProduct(void Function(String) setter) async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => const BarcodeScannerBottomSheet(),
      );

      if (result == null) throw Exception("바코드를 인식하지 못했습니다.\n다시 시도해주세요.");

      final resultMap = await PutawayAndPickingController.getLocationInfo(
        context,
        result,
      );

      setState(() {
        _backGroundColor = resultMap['backGroundColor'] as Color;
        _resultIcon = resultMap['icon'] as IconData;
        _message = resultMap['message'].toString();
        _warehouseCd = resultMap['wareHouseCd'].toString() ?? "";
        _warehouseNm = resultMap['wareHouseNm'].toString() ?? "";
        _zoneCd = resultMap['zoneCd'].toString() ?? "";
        _zoneNm = resultMap['zoneNm'].toString() ?? "";
        _cellCd = resultMap['cellCd'].toString() ?? "";
        _cellNm = resultMap['cellNm'].toString() ?? "";

        _locationBarcode = result;
        _scanLocationtResult = true;
      });
    } catch (e) {
      setState(() {
        _backGroundColor = Colors.grey;
        _resultIcon = Icons.error;
        _message = e.toString();
        _scanLocationtResult = false;
      });
    }
  }

  Future<void> putAway() async {
    try {
      if (_productBarcode?.isEmpty ?? true)
        throw Exception("대상 바코드가 스캔되지 않았습니다.");

      if (_locationBarcode?.isEmpty ?? true)
        throw Exception("장소 바코드가 스캔되지 않았습니다.");

      final resultMap = await PutawayAndPickingController.productPutAway(
        context,
        _productBarcode,
        _locationBarcode,
      );

      setState(() {
        _backGroundColor = resultMap['backGroundColor'] as Color;
        _resultIcon = resultMap['icon'] as IconData;
        _message = resultMap['message'].toString();
      });
    } catch (e) {
      setState(() {
        _backGroundColor = Colors.grey;
        _resultIcon = Icons.error;
        _message = e.toString();
      });
    }
  }

  Future<void> picking() async {
    try {
      final resultMap = await PutawayAndPickingController.productPicking(
        context,
        _productBarcode,
      );
      setState(() {
        _backGroundColor = resultMap['backGroundColor'] as Color;
        _resultIcon = resultMap['icon'] as IconData;
        _message = resultMap['message'].toString();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("적치/피킹", style: AppTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 94, 176, 255),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProductCard(),

            _buildLocationCard(),
            const SizedBox(height: 10),
            _resultBar(_backGroundColor, _resultIcon, _message),
            const SizedBox(height: 25),
            _buildButtonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _band(Icons.inventory, "대상정보"),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                //함수를 호출 함수의 호출후 콜백으로 값을 받아오는 문법
                _buildBarcodeBox(
                  _productBarcode,
                  () => scanProduct((v) => _productBarcode = v),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("품목코드", _itemCd),
                      _infoRow("품목명", _itemNm),
                      _infoRow("제조번호", _receiptLotNo),
                      _infoRow("유효기간", _receiptValidDate),
                      _infoRow("입고량", _receiptPackQty),
                      _infoRow("재고량", _receiptPackRemainQty),
                      _infoRow("상태", _receiptStatus),
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

  Widget _buildBarcodeBox(String? barcode, VoidCallback FncOnTap) {
    return InkWell(
      onTap: FncOnTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: barcode?.isEmpty ?? true ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: barcode?.isEmpty ?? true
              ? Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey)
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

  Widget _buildButtonGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 15,
      childAspectRatio: 3.3,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.archive, color: Colors.blue, size: 30),
          label: const Text(
            "적치",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          onPressed: () async {
            await putAway();
          },

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.unarchive, color: Colors.blue, size: 30),
          label: const Text(
            "피킹",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          onPressed: () async {
            await picking();
          },

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
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
