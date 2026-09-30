import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuantityButton extends StatelessWidget {
  final int quantity;
  final int stock;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isCompact;

  const QuantityButton({
    super.key,
    required this.quantity,
    required this.stock,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stock <= 0) {
      return Container(
        height: isCompact ? 32 : 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    if (quantity == 0) {
      return SizedBox(
        height: isCompact ? 32 : 38,
        child: ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.secondary,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'ADD',
            style: TextStyle(
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    // Interactive quantity increment / decrement pill
    return Container(
      height: isCompact ? 32 : 38,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 14, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: isCompact ? 28 : 34),
            onPressed: onDecrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 14,
              color: quantity >= stock ? Colors.white38 : Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: isCompact ? 28 : 34),
            onPressed: quantity >= stock ? null : onIncrease,
          ),
        ],
      ),
    );
  }
}
