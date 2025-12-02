import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Affichage du PIN avec points masqués et animation du dernier caractère
class PinDisplay extends StatelessWidget {
  final String pin;
  final bool showLastChar;
  final bool compact;

  const PinDisplay({
    super.key,
    required this.pin,
    this.showLastChar = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 50 : 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pin.length, (index) {
          final bool isLast = index == pin.length - 1;
          final bool shouldShowChar = isLast && showLastChar;
          final String char = pin[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            alignment: Alignment.center,
            child: shouldShowChar
                ? Text(
                    char,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: compact ? 30 : 36,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
