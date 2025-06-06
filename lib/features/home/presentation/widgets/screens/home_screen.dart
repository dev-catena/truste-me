import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/routes.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/generic_error_component.dart';
import '../../../../conection/presentation/blocs/connection_panel_bloc.dart';
import '../../../data/data_source/home_datasource.dart';
import '../../../data/models/feature_data.dart';
import '../../blocs/home_bloc.dart';
import '../components/summary_card.dart';
import '../components/user_info_component.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final bloc = HomeBloc(HomeDataSource());

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    final List<FeatureData> features = [
      FeatureData(name: 'Conexões', icon: Symbols.partner_exchange, destinationRoute: AppRoutes.connectionPanelScreen),
      FeatureData(name: 'Selos', icon: Symbols.asterisk, destinationRoute: AppRoutes.contractsScreen),
      // FeatureData(name: 'Carteira', icon: Symbols.account_balance_wallet, destinationRoute: AppRoutes.contractsScreen),
    ];

    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações gerais', style: titleLarge, textAlign: TextAlign.start),
          const SizedBox(height: 10),
          const UserInfoComponent(),
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
    );

    return CustomScaffold(
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: bloc,
        builder: (_, state) {
          if (state is HomeInitial) {
            bloc.add(HomeStarted());
            return const CircularProgressIndicator();
          } else if (state is HomeLoadInProgress) {
            return const CircularProgressIndicator();
          } else if (state is HomeReady) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informações gerais', style: titleLarge, textAlign: TextAlign.start),
                const SizedBox(height: 10),
                const UserInfoComponent(),
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
            );
          } else if (state is HomeError) {
            return GenericErrorComponent(state.msg, onRefresh: () => bloc.add(HomeStarted()));
          } else {
            return Column(
              children: [
                const Text('NoState'),
                IconButton(onPressed: () => bloc.add(HomeStarted()), icon: const Icon(Icons.refresh_outlined))
              ],
            );
          }
        },
      ),
    );
  }
}
