import 'package:flutter/material.dart';

/// Optional styling for the scanner overlay label.
///
/// Non-null fields override the platform default appearance.
class OverlayLabelStyle {
  const OverlayLabelStyle({
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.paddingHorizontal,
    this.paddingVertical,
    this.borderRadius,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final double? borderRadius;

  /// 32-bit ARGB encoding for the native channel.
  static int? _colorToArgb32(Color? color) {
    if (color == null) return null;
    final a = (color.a * 255.0).round() & 0xff;
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  /// Map for [MethodChannel]; keys aligned with Android/iOS.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (backgroundColor != null) 'backgroundColor': _colorToArgb32(backgroundColor),
      if (textColor != null) 'textColor': _colorToArgb32(textColor),
      if (fontSize != null) 'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight!.value,
      if (paddingHorizontal != null) 'paddingHorizontal': paddingHorizontal,
      if (paddingVertical != null) 'paddingVertical': paddingVertical,
      if (borderRadius != null) 'borderRadius': borderRadius,
    };
  }

  bool get isEmpty => toMap().isEmpty;
}
