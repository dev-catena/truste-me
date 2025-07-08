import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_data_cubit.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
import '../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../conection/presentation/widgets/components/seals_board.dart';
import '../../../login/data/data_source/login_datasource.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();
    final appData = context.read<AppDataCubit>();

    return CustomScaffold(
      child: RefreshIndicator(
        onRefresh: () => userData.initialize(userLoggedIn).whenComplete(() => setState(() {})),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              userData.getUser.buildSummaryCard(),
              const SizedBox(height: 10),
              SealsBoard(userData.getUser.sealsObtained, canGetSeal: true),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Sair'),
                leading: const Icon(Icons.logout_outlined, color: CustomColor.vividRed),
                onTap: () {
                  LoginDataSource(true, userData, appData)
                      .logout()
                      .whenComplete(() => context.goNamed(AppRoutes.loginScreen));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
