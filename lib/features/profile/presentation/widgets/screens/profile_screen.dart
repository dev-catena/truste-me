import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/routes.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../../../main.dart';
import '../../../../common/domain/entities/user.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../conection/presentation/widgets/components/seals_board.dart';
import '../../../../login/data/data_source/login_datasource.dart';
import '../../../../login/data/data_source/logout_datasource.dart';

class ProfileScreen extends StatefulWidget {
  final bool showEditButton;
  final bool showSealsInfo;
  const ProfileScreen({super.key, this.showEditButton = true, this.showSealsInfo = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();
    final appData = context.read<AppDataCubit>();

    return CustomScaffold(
      showAvatar: false,
      child: RefreshIndicator(
        onRefresh: () => userData.initialize(userLoggedIn).whenComplete(() => setState(() {})),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              userData.getUser.buildSummaryCard(isLoggedUser: true, showEditButton: widget.showEditButton),
              Visibility(
                visible: widget.showSealsInfo,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SealsBoard(userData.getUser.sealsObtained, canGetSeal: true),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Sair'),
                leading: const Icon(Icons.logout_outlined, color: CustomColor.vividRed),
                onTap: () {
                  TrustMeApp.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
