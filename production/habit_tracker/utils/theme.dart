import 'package:flutter/material.dart';

const primary = Color(0xFF6C63FF);
const background = Color(0xFFF6F7FF);

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: background,
  fontFamily: "Poppins",
  colorScheme: ColorScheme.fromSeed(seedColor: primary),
);
