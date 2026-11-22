import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/widgets/home_screen/navigation_item.dart';
import 'package:monvexa/widgets/home_screen/nav_bar_item.dart';

class LiquidGlassNavBar extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double? bottomMargin;

  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.bottomMargin,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final effectiveBottom = bottomMargin ?? (bottomPad > 0 ? bottomPad + 8 : 16.0);

    return Padding(
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
        bottom: effectiveBottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),

              // Glossy glass gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withAlpha(245), // 0.96 * 255
                  AppColors.surface.withAlpha(240), // 0.94 * 255
                  const Color(0xFFDCEFE8).withAlpha(245), // 0.96 * 255
                ],
                stops: const [0.0, 0.48, 1.0],
              ),

              border: Border.all(
                color: Colors.white.withAlpha(242), // 0.95 * 255
                width: 1.2,
              ),

              // Floating 3D shadows
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withAlpha(41), // 0.16 * 255
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppColors.primary.withAlpha(26), // 0.10 * 255
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(166), // 0.65 * 255
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (i) {
                    return NavBarItem(
                      item: items[i],
                      isSelected: i == selectedIndex,
                      index: i,
                      onTap: () => onTap(i),
                    );
                  }),
                ),

                // Top glass reflection
                Positioned(
                  top: 1,
                  left: 35,
                  right: 35,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withAlpha(0),
                          Colors.white,
                          Colors.white.withAlpha(0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
