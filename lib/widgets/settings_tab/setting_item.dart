
import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/widgets/common/glass_container.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key, required this.title, required this.icon, required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GlassContainer(
        showBorder: true,
        tint: AppColors.primary.withAlpha(1),
        padding: .symmetric(vertical: 20, horizontal: 10),
       
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18)),
            Spacer(),
            Icon(IconConst.forwardArrow, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
