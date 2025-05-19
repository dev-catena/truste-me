import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../conection/presentation/widgets/components/seals_board.dart';
import '../../../login/data/data_source/login_datasource.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return CustomScaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            userData.getUser.buildSummaryCard(),
            const SizedBox(height: 10),
            SealsBoard(userData.getUser.sealsObtained ?? [], canBuySeal: true),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Sair'),
              leading: const Icon(Icons.logout_outlined, color: CustomColor.vividRed),
              onTap: () {
                LoginDataSource(true, userData).logout().whenComplete(() => context.goNamed(AppRoutes.loginScreen));
              },
            )
          ],
        ),
      ),
    );
  }
}
