import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/enums/contract_status.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/routes.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../common/presentation/widgets/components/stateful_filter_chips.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({this.initialFilter, super.key});

  final String? initialFilter;

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  late String activeFilter;

  void setFilter(String filterSelected) {
    setState(() {
      activeFilter = filterSelected;
    });
  }

  @override
  void initState() {
    setFilter(widget.initialFilter ?? 'Todos');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userData = context.read<UserDataCubit>();

    return CustomScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(AppRoutes.newContractScreen);
        },
        child: const Icon(Icons.add),
      ),
      child: BlocBuilder<UserDataCubit, UserDataState>(
        builder: (_, state) {
          if (state is UserDataReady) {
            final allContracts = state.contracts;

            final filteredContracts = activeFilter == 'Todos'
                ? allContracts.where((element) => element.status != ContractStatus.expired).toList()
                : allContracts.where((c) => c.status.description == activeFilter).toList();

            return RefreshIndicator(
              onRefresh: () async => userData.refreshContracts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HeaderLine('Contratos', Symbols.contract),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: size.width * 0.95,
                      child: StatefulFilterChips(
                        filtersLabel: ContractStatus.values.map((e) => e.description).toList()..insert(0, 'Todos'),
                        initialFilter: activeFilter,
                        onSelected: setFilter,
                      ),
                    ),
                    const SizedBox(height: 20),
                    filteredContracts.isEmpty
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
                            itemCount: filteredContracts.length,
                            itemBuilder: (_, index) {
                              final contract = filteredContracts[index];

                              return contract.buildCard(
                                onExpire: (contract) {
                                  final allContractIndex = allContracts.indexOf(contract);

                                  // if(contract.status == ContractStatus.pending){
                                  if(contract.status == ContractStatus.expired){
                                    allContracts[allContractIndex] = contract.copyWith(status: ContractStatus.expired);
                                  // } else if (contract.status == ContractStatus.active){
                                  } else if (contract.status == ContractStatus.pending){
                                    allContracts[allContractIndex] = contract.copyWith(status: ContractStatus.completed);
                                  }
                                  debugPrint('$runtimeType - onExpire called');
                                  if(context.mounted) {
                                    setState(() {});
                                  }
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            );
          } else {
            return const Text('No state');
          }
        },
      ),
    );
  }
}
