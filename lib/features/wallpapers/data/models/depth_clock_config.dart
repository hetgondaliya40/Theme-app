import 'package:flutter/material.dart';

class DepthClockConfig {
  final String fontFamily;
  final double fontSizePercent;
  final Color clockColor;
  final Color shadowColor;
  final double verticalPositionPercent;
  final bool isBehindForeground;
  final bool showClock;
  final bool showDate;

  const DepthClockConfig({
    this.fontFamily = 'Outfit',
    this.fontSizePercent = 24.0,
    this.clockColor = Colors.white,
    this.shadowColor = const Color(0x99000000),
    this.verticalPositionPercent = 24.0,
    this.isBehindForeground = true,
    this.showClock = false,
    this.showDate = false,
  });

  DepthClockConfig copyWith({
    String? fontFamily,
    double? fontSizePercent,
    Color? clockColor,
    Color? shadowColor,
    double? verticalPositionPercent,
    bool? isBehindForeground,
    bool? showClock,
    bool? showDate,
  }) {
    return DepthClockConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizePercent: fontSizePercent ?? this.fontSizePercent,
      clockColor: clockColor ?? this.clockColor,
      shadowColor: shadowColor ?? this.shadowColor,
      verticalPositionPercent:
          verticalPositionPercent ?? this.verticalPositionPercent,
      isBehindForeground: isBehindForeground ?? this.isBehindForeground,
      showClock: showClock ?? this.showClock,
      showDate: showDate ?? this.showDate,
    );
  }
}
