import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeBox extends StatelessWidget {
  final String? barcode;
  final VoidCallback onTap;

  const BarcodeBox({Key? key, required this.barcode, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 350,
        height: 80,
        decoration: BoxDecoration(
          color: barcode == null ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(12),

        ),
        child: Center(
          child: barcode == null
              ? Icon(Icons.qr_code_scanner, size: 40, color: Colors.grey)
              : BarcodeWidget(
            barcode: Barcode.code128(),
            data: barcode!,

            drawText: true,
          ),
        ),
      ),
    );
  }
}
