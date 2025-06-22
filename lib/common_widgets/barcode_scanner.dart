import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerBottomSheet extends StatefulWidget {
  const BarcodeScannerBottomSheet({super.key});

  @override
  State<BarcodeScannerBottomSheet> createState() => _BarcodeScannerBottomSheetState();
}

class _BarcodeScannerBottomSheetState extends State<BarcodeScannerBottomSheet> {
  bool isScanned = false;
  final MobileScannerController controller = MobileScannerController();

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return; // 중복 방지
    final barcode = capture.barcodes.first.rawValue ?? '';

    if (barcode.isNotEmpty) {
      setState(() {
        isScanned = true;
      });

      controller.stop();  // 카메라 멈춤
      Navigator.of(context).pop(barcode);  // 결과값 리턴하면서 바텀시트 닫기
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('바코드 스캔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: onDetect,
            ),
          ),
        ],
      ),
    );
  }
}
