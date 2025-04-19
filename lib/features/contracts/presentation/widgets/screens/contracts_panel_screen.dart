import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/routes.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../blocs/contract_panel/contract_panel_bloc.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContractPanelBloc>(
      create: (_) => ContractPanelBloc(ContractDataSource()),
      child: CustomScaffold(
        floatingActionButton: BlocSelector<ContractPanelBloc, ContractPanelState, bool>(
          selector: (state) => state is ContractPanelReady,
          builder: (context, isReady) {
            if (isReady) {
              return FloatingActionButton(
                onPressed: () {
                  context.pushNamed(AppRoutes.newContractScreen);
                },
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        child: BlocBuilder<ContractPanelBloc, ContractPanelState>(
          builder: (ctx, state) {
            final bloc = ctx.read<ContractPanelBloc>();
            if (state is ContractPanelInitial) {
              bloc.add(ContractPanelStarted());
              return const CircularProgressIndicator();
            } else if (state is ContractPanelReady) {
              return _ReadyScreen(state);
            } else if (state is ContractPanelError) {
              return Text(state.msg);
            } else {
              return Column(
                children: [
                  const Text('NoState'),
                  IconButton(
                      onPressed: () => bloc.add(ContractPanelStarted()), icon: const Icon(Icons.refresh_outlined))
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class _ReadyScreen extends StatelessWidget {
  const _ReadyScreen(this.state);

  final ContractPanelReady state;

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: () async => context.read<ContractPanelBloc>().add(ContractPanelStarted()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeaderLine('Contratos', Symbols.contract),
            const SizedBox(height: 20),
            state.contracts.isEmpty
                ? const Text('Nenhum contrato existente')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: state.contracts.length,
                    itemBuilder: (_, index) {
                      final contract = state.contracts[index];

                      return contract.buildCard();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
