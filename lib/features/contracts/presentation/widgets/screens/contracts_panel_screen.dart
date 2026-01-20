import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:trustme/core/extensions/context_extensions.dart';

import 'package:trustme/core/enums/contract_status.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/common/presentation/widgets/components/generic_error_component.dart';
import 'package:trustme/features/common/presentation/widgets/components/header_line.dart';
import 'package:trustme/features/common/presentation/widgets/components/stateful_filter_chips.dart';

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
          context.pushNamed(AppRoutes.newContractScreen).then((value) {
            // The listener will show the result of the refresh.
            userData.refreshContracts(showSnackbar: false);
          });
        },
        child: const Icon(Icons.add),
      ),
      child: BlocConsumer<UserDataCubit, UserDataState>(
        listener: (context, state) {
          if (state is UserDataReady && state.event is RefreshResult) {
            final event = state.event as RefreshResult;
            context.showSnack(event.message);
            userData.clearEvent();
          }
        },
        builder: (_, state) {
          if (state is UserDataError) {
            // Use the global userLoggedIn variable to re-initialize
            return GenericErrorComponent(state.message, onRefresh: () async => userData.initialize(userLoggedIn));
          }

          if (state is UserDataInitial || state is UserDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserDataReady) {
            final allContracts = state.contracts;

            final filteredContracts = activeFilter == 'Todos'
                ? allContracts.where((element) => element.status != ContractStatus.expired).toList()
                : allContracts.where((c) => c.status.description == activeFilter).toList();

            return RefreshIndicator(
              onRefresh: () async => userData.refreshContracts(showSnackbar: true),
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
                        filtersLabel: ContractStatus.values.map((e) => e.description).toList()..add('Todos'),
                        initialFilter: activeFilter,
                        onSelected: setFilter,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (filteredContracts.isEmpty)
                      const Text('Nenhum contrato'),
                    if (filteredContracts.isEmpty)
                      IconButton(
                        onPressed: () => userData.refreshContracts(),
                        icon: const Icon(Icons.refresh_outlined),
                      ),
                    if (!filteredContracts.isEmpty)
                      GridView.builder(
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
                            onExpire: (expiredContract) {
                              // Based on the old logic, a pending contract becomes completed.
                              // Let's follow that, but using the Cubit to manage the state.
                              if (expiredContract.status == ContractStatus.pending) {
                                userData.updateLocalContract(expiredContract.copyWith(status: ContractStatus.completed));
                              } else {
                                // For other statuses (like active), we'll mark as expired.
                                userData.updateLocalContract(expiredContract.copyWith(status: ContractStatus.expired));
                              }
                            },
                            onReloadList: () {
                              userData.refreshContracts(showSnackbar: false);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Estado inesperado'));
        },
      ),
    );
  }
}
