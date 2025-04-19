import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/person.dart';
import '../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../conection/presentation/widgets/components/seals_board.dart';
import '../../../login/data/data_source/login_datasource.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(this.user, {super.key});

  final Person user;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            user.buildSummaryCard(),
            const SizedBox(height: 10),
            SealsBoard(user.sealsObtained ?? [], canBuySeal: true),
            const SizedBox(height: 10),
            ListTile(
              title: Text('Sair'),
              leading: Icon(Icons.logout_outlined, color: CustomColor.vividRed),
              onTap: () {
                LoginDataSource(true).logout().whenComplete(() => context.goNamed(AppRoutes.loginScreen));
              },
            )
          ],
        ),
      ),
    );
  }
}
