import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  (Color, Color) _getColors() {
    final s = status.toUpperCase();
    if (s == 'DELIVERED' || s == 'IN STOCK' || s == 'ACTIVE' || s == 'PAID') {
      return (AppColors.successLight, AppColors.success);
    }
    if (s == 'OUT OF STOCK' || s == 'CANCELLED' || s == 'INACTIVE') {
      return (AppColors.errorLight, AppColors.error);
    }
    if (s == 'LOW STOCK' || s == 'PREPARING' || s == 'PENDING') {
      return (AppColors.warningLight, AppColors.warning);
    }
    if (s == 'PLACED' || s == 'CONFIRMED' || s == 'OUT FOR DELIVERY') {
      return (AppColors.infoLight, AppColors.info);
    }
    return (AppColors.surface, AppColors.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
