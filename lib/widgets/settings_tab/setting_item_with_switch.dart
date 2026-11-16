import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/controller/tabs/settings_tab_controller.dart';

class SettingItemWithSwitch extends StatelessWidget {
  const SettingItemWithSwitch({
    super.key,
    required this.title,
    required this.icon,
    required this.settingKey,
  });

  final String title;
  final IconData icon;
  final String settingKey;

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Obx(
            () => Switch(
              value: controller.settings[settingKey] ?? false,
              activeColor: AppColors.primary,
              onChanged: (value) {
                controller.updateSetting(settingKey, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}