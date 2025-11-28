import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';

import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/common/presentation/widgets/components/header_line.dart';
import 'package:trustme/features/connection/presentation/widgets/components/seals_board.dart';

class SealsScreen extends StatelessWidget {
  final bool onlyPendingSeals;

  const SealsScreen({super.key, this.onlyPendingSeals = false,});

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
                    const HeaderLine('Selos', Symbols.asterisk),
                    //const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SealsBoard(state.user.sealsObtained, canGetSeal: true, showTitle: false, onlyPendingSeals: onlyPendingSeals),
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
