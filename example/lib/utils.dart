import 'package:flutter/material.dart';

class FontWeightUtils {
  ///400
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
}

class ColorUtils {
  static const Color blueColor = Color(0xff2cabec);
  static Color blueBGColor = fromHex("#1A216EFF");
  static const Color lineColor = Color(0x1A000000);
  static Color backgroudColor = fromHex("#FFF6F8FF");
  static Color redColor = fromHex("FFFF233E");

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
