import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFFD400); // QuickCart Yellow
  static const Color primaryDark = Color(0xFFE5BE00);
  static const Color primaryLight = Color(0xFFFFF1A8);
  static const Color secondary = Color(0xFF111111); // Rich Dark
  
  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F7F8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF1F3F5);
  
  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Typography Colors
  static const Color text = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Accent Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFDF38), Color(0xFFFFC700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
