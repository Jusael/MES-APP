import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatDecimal {
  static String formatDecimal(dynamic value) {
    if (value == null) return '';

    double? numValue = double.tryParse(value.toString());
    if (numValue == null) return value.toString();

    // 천단위 콤마 + 소수점 최대 6자리 (의미 없는 0 제거)
    NumberFormat formatter = NumberFormat('#,##0.######');
    return formatter.format(numValue);
  }
}
