import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData miPropioTema = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(255, 255, 111, 0),
    scaffoldBackgroundColor: Color.fromRGBO(245, 136, 46, 1),
    fontFamily: 'Raleway',
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFFF6F00),
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF6F00),
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 0, 131, 253),
      onSecondary: Color.fromARGB(255, 109, 0, 199),
      surface: Colors.white,
      onSurface: Color(0xFF212121),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 148, 30, 226),
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 0, 0)),
      titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 0, 0, 0)),
      bodyMedium: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 148, 30, 226)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0288D1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color.fromARGB(255, 148, 30, 226)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFFF6F00)),
      ),
      labelStyle: TextStyle(color: Color(0xFF424242)),
    ),
  );
}
