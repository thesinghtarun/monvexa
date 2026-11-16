import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/constants/string_const.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(38),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: .only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  StringConst.hello,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                //Account Selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3F1FF), Color(0xFFFFE8D5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     
                      const Text(
                        'Personal Account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF252525),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: Color(0xFF555555),
                      ),
                    ],
                  ),
                ),

                //Add Another Account
                InkWell(
                  onTap: () {
                    // Handle add button tap
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18.0,
                    child: Icon(
                      IconConst.add,
                      size: 30.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
