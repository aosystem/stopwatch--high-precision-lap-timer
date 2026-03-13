import 'package:flutter/material.dart';

import 'package:stopwatch/model.dart';

class ThemeColor {
  final int? themeNumber;
  final BuildContext context;

  ThemeColor({this.themeNumber, required this.context});

  Brightness get _effectiveBrightness {
    switch (themeNumber) {
      case 1:
        return Brightness.light;
      case 2:
        return Brightness.dark;
      default:
        return Theme.of(context).brightness;
    }
  }

  Color _getRainbowAccentColor(int hue, double saturation) {
    return HSVColor.fromAHSV(1.0, hue.toDouble(), saturation, 1.0).toColor();
  }

  bool get _isLight => _effectiveBrightness == Brightness.light;

  //main page
  Color get mainBackColor => _isLight ? Color.fromRGBO(106, 69, 51, 1.0) : Color.fromRGBO(40,20,20, 1.0);
  Color get mainBack2Color => _isLight ? Color.fromRGBO(21, 11, 8, 1.0) : Color.fromRGBO(0, 0, 0, 1.0);
  Color get mainCardColor => _isLight ? Color.fromRGBO(255, 255, 255, 1.0) : Color.fromRGBO(51, 51, 51, 1.0);
  Color get mainForeColor => _isLight ? Color.fromRGBO(200, 200, 200, 1.0) : Color.fromRGBO(200, 200, 200, 1.0);
  Color get mainAccentForeColor => _getRainbowAccentColor(Model.schemeColor,0.6);
  //main page image
  String get mainStopwatchHead => _isLight ? 'assets/image/stopwatch_head.png' : 'assets/image/stopwatch_head2.png';
  String get mainStopwatchBody => _isLight ? 'assets/image/stopwatch_body.png' : 'assets/image/stopwatch_body2.png';
  String get mainStopwatchNeedleBlack => _isLight ? 'assets/image/stopwatch_needle_black.png' : 'assets/image/stopwatch_needle_black2.png';
  String get mainStopwatchNeedleRed => _isLight ? 'assets/image/stopwatch_needle_red.png' : 'assets/image/stopwatch_needle_red.png';
  //setting page
  Color get backColor => _isLight ? Colors.grey[200]! : Colors.grey[900]!;
  Color get cardColor => _isLight ? Colors.white : Colors.grey[800]!;
  Color get appBarForegroundColor => _isLight ? Colors.grey[700]! : Colors.white70;
  Color get dropdownColor => cardColor;
  Color get borderColor => _isLight ? Colors.grey[300]! : Colors.grey[700]!;
  Color get inputFillColor => _isLight ? Colors.grey[50]! : Colors.grey[900]!;
}
