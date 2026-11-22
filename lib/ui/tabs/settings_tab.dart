import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/widgets/settings_tab/setting_item.dart';
import 'package:monvexa/widgets/settings_tab/setting_item_with_switch.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: .only(left: 10, right: 10, bottom: 110),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  StringConst.settings,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              SettingItem(
                title: StringConst.language,
                icon: IconConst.language,
                onTap: () {},
              ),
             
              SizedBox(height: 10),
              SettingItemWithSwitch(
                title: StringConst.notification,
                icon: IconConst.notification,
                settingKey: 'notifications',
              ),
              SizedBox(height: 10),
              SettingItemWithSwitch(
                title: StringConst.biometric,
                icon: IconConst.biometric,
                settingKey: 'biometric',
              ),
              SizedBox(height: 10),
              SettingItem(
                title: StringConst.privacyPolicy,
                icon: IconConst.privacyPolicy,
                onTap: () {},
              ),
              SizedBox(height: 10),
              SettingItem(
                title: StringConst.feedback,
                icon: IconConst.feedback,
                onTap: () {},
              ),
              SizedBox(height: 10),
              SettingItem(
                title: StringConst.rateUs,
                icon: IconConst.rateUs,
                onTap: () {},
              ),
              SizedBox(height: 10),
              SettingItem(
                title: StringConst.shareApp,
                icon: IconConst.shareApp,
                onTap: () {},
              ),
              SizedBox(height: 10),
              SettingItem(
                title: StringConst.aboutApp,
                icon: IconConst.aboutApp,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
