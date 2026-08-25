import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFF185FA5);
  static const bgAccent = Color(0xFFE6F1FB);
  static const success = Color(0xFF3B6D11);
  static const danger = Color(0xFFA32D2D);
  static const bgDanger = Color(0xFFFCEBEB);

  static const amberBg = Color(0xFFFAEEDA);
  static const amberFg = Color(0xFF854F0B);
  static const tealBg = Color(0xFFE1F5EE);
  static const tealFg = Color(0xFF0F6E56);
  static const grayBg = Color(0xFFF1EFE8);
  static const grayFg = Color(0xFF5F5E5A);
  static const blueBg = Color(0xFFE6F1FB);
  static const blueFg = Color(0xFF185FA5);
  static const coralBg = Color(0xFFFAECE7);
  static const coralFg = Color(0xFF993C1D);
  static const greenBg = Color(0xFFEAF3DE);
  static const greenFg = Color(0xFF3B6D11);
  static const redBg = Color(0xFFFCEBEB);
  static const redFg = Color(0xFFA32D2D);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F5F0),
    fontFamily: 'Roboto',
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF1EFE8),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
