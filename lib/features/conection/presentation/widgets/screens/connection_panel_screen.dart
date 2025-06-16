import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/enums/connection_status.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../common/presentation/widgets/components/stateful_filter_chips.dart';
import '../../../domain/entities/connection.dart';
import '../dialogs/request_connection_dialog.dart';

class ConnectionPanelScreen extends StatefulWidget {
  const ConnectionPanelScreen({super.key, this.initialFilter});
  final String? initialFilter;

  @override
  State<ConnectionPanelScreen> createState() => _ConnectionPanelScreenState();
}

class _ConnectionPanelScreenState extends State<ConnectionPanelScreen> {
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
        heroTag: 'btn1',
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return RequestConnectionDialog(onRequested: userData.requestConnection);
              });
        },
        child: const Icon(Icons.add),
      ),
      child: BlocConsumer<UserDataCubit, UserDataState>(
        bloc: userData,
        listener: (context, state) {
          if (state is UserDataReady) {
            if (state.connectionRequestStatus == ConnectionRequestStatus.failure) {
              context.showSnack(state.requestMessage);

            } else if (state.connectionRequestStatus == ConnectionRequestStatus.success) {
              context.showSnack('Conexão solicitada!');
            }
          }
        },
        builder: (_, state) {
          if (state is UserDataReady) {
            final allConnections = state.connections;

            final filteredConnections = activeFilter == 'Todos'
                ? allConnections
                : allConnections.where((c) => c.status.description == activeFilter).toList();

            return Column(
              children: [
                const HeaderLine('Conexões', Symbols.partner_exchange),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  width: size.width * 0.95,
                  child: StatefulFilterChips(
                    filtersLabel: ConnectionStatus.values.map((e) => e.description).toList()..insert(0, 'Todos'),
                    initialFilter: activeFilter,
                    onSelected: (value) => setFilter(value),
                  ),
                ),
                const SizedBox(height: 12),
                filteredConnections.isEmpty
                    ? Column(
                        children: [
                          const Text('Nenhuma conexão'),
                          IconButton(
                            onPressed: () => userData.refreshConnections(userData.getUser),
                            icon: const Icon(Icons.refresh_outlined),
                          ),
                        ],
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => await userData.refreshConnections(userData.getUser),
                          child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (_, __) {
                              return const SizedBox(height: 10);
                            },
                            itemCount: filteredConnections.length,
                            itemBuilder: (context, index) {
                              final connection = filteredConnections[index];

                              return connection.buildTile();
                            },
                          ),
                        ),
                      ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
