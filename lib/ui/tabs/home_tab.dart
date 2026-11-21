import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/image_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/widgets/home_tab/account_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return SafeArea(
      top: false,
      child: Obx(() {
        final state = controller.uiState.value;

        if (state == 'loading') {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state == 'noAccount') {
          return const _NoAccountView();
        }

        return Column(
          children: [
            const AccountCard(),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  StringConst.recentTransactions,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    height: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 3,
                    ),
                    leading: const Icon(Icons.attach_money),
                    title: Text('Transaction ${index + 1}'),
                    subtitle: Text('Description of transaction ${index + 1}'),
                    trailing: Text('-\$${(index + 1) * 10}'),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _NoAccountView extends StatelessWidget {
  const _NoAccountView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageConst.noAccountFound, width: 400, height: 400),

          const SizedBox(height: 16),

          const Text(
            StringConst.noAccountFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            StringConst.tapBelowToAddAccount,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 26),

          // Scan & Detect Accounts Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.accountDetection)?.then((_) {
                    HomeTabController.to.loadAccountsFromDb();
                  });
                },
                icon: const Icon(Icons.document_scanner_rounded, size: 20),
                label: const Text(
                  'Scan & Detect Accounts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
