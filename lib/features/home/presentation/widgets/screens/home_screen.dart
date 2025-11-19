import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:trustme/core/providers/app_data_cubit.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/common/presentation/widgets/components/generic_error_component.dart';
import 'package:trustme/features/home/data/data_source/home_datasource.dart';
import 'package:trustme/features/home/data/models/feature_data.dart';
import 'package:trustme/features/home/presentation/blocs/home_bloc.dart';
import 'package:trustme/features/home/presentation/widgets/components/user_home_info_component.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    final List<FeatureData> features = [
      FeatureData(name: 'Conexões', icon: Symbols.partner_exchange, destinationRoute: AppRoutes.connectionPanelScreen),
      FeatureData(name: 'Selos', icon: Symbols.asterisk, destinationRoute: AppRoutes.sealsScreen),
    ];

    return CustomScaffold(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (blocCtx, homeState) {
          final bloc = blocCtx.read<HomeBloc>();

          if (homeState is HomeReady) {
            return RefreshIndicator(
              onRefresh: () async => bloc.add(HomeStarted()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informações gerais', style: titleLarge, textAlign: TextAlign.start),
                    const SizedBox(height: 10),
                    const UserHomeInfoComponent(),
                    const SizedBox(height: 20),
                    Text('Serviços', style: titleLarge, textAlign: TextAlign.start),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(
                        features.length,
                        (index) {
                          return features[index].buildCard();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (homeState is HomeLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (homeState is HomeError) {
            return GenericErrorComponent(homeState.msg, onRefresh: () async => bloc.add(HomeStarted()));
          } else {
            // Initial State
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
