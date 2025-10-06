import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';

import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/main.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/conection/presentation/widgets/components/seals_board.dart';

class ProfileScreen extends StatelessWidget {
  final bool showEditButton;
  final bool showSealsInfo;

  const ProfileScreen({
    super.key,
    this.showEditButton = true,
    this.showSealsInfo = true,
  });

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<UserDataCubit, UserDataState>(
      builder: (context, state) {

        if (state is UserDataReady) {
          return CustomScaffold(
            showAvatar: false,
            child: RefreshIndicator(
              onRefresh: () => context.read<UserDataCubit>().initialize(state.user),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    state.user.buildSummaryCard(
                      isLoggedUser: true,
                      showEditButton: showEditButton,
                    ),
                    Visibility(
                      visible: showSealsInfo,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SealsBoard(state.user.sealsObtained, canGetSeal: true),
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
        } else {
          return Container();
        }
      },
    );
  }
}
