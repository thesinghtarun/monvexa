import 'package:material_ui/material_ui.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/widgets/home_tab/account_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          AccountCard(),
          SizedBox(height: 20.0),
          Padding(
            padding: .only(left: 20, right: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                StringConst.recentTransactions,

                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  height: 0,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              padding: .only(bottom: 100),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Transaction ${index + 1}'),
                  subtitle: Text('Description of transaction ${index + 1}'),
                  trailing: Text('-\$${(index + 1) * 10}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
