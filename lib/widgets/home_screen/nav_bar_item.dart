import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/widgets/home_screen/navigation_item.dart';

class NavBarItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D animated teal selector
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              builder: (context, value, child) {
                // Settings (index 3): Rotation animation
                if (index == 3) {
                  return Transform.rotate(
                    angle: value * 2 * math.pi,
                    child: child,
                  );
                }

                // Home, Scan, Transactions: Zoom animation
                return Transform.scale(
                  scale: 1.0 + (0.2 * value),
                  child: child,
                );
              },
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withAlpha(179),
              ),
            ),
            const SizedBox(height: 4),
            // Navigation label
            TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 250),
              tween: ColorTween(
                begin: isSelected
                    ? AppColors.textSecondary.withAlpha(179) // 0.7 * 255
                    : AppColors.primary,
                end: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withAlpha(179), // 0.7 * 255
              ),
              builder: (context, color, _) {
                return Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: 0.1,
                    shadows: const [],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
