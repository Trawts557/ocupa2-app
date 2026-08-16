import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF0B3558);
  static const Color secondary = Color(0xFFFF7A2F);

  // Backgrounds
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Colors.white;

  // Borders / dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // States
  static const Color success = Color(0xFF35B87F);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFD64545);

  // Extra UI
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF3F4F6);

    // Colores semánticos para estados (agregados por Persona 4)
  static const Color danger  = Color(0xFFC62828); // rojo: descartado
  static const Color info    = Color(0xFF546E7A); // gris azulado: en revisión
}