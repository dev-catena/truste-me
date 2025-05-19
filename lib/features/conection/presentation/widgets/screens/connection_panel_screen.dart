import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/generic_error_component.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../data/data_source/connection_datasource.dart';
import '../../blocs/connection_panel_bloc.dart';
import '../dialogs/request_connection_dialog.dart';

class ConnectionPanelScreen extends StatelessWidget {
  const ConnectionPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: BlocBuilder<UserDataCubit, UserDataState>(
        builder: (context, state) {
          if (state is UserDataReady) {
            return Column(
              children: [
                const HeaderLine('Conexões', Symbols.partner_exchange),
                const SizedBox(height: 12),
                state.connections.isEmpty
                    ? const Text('Nenhuma conexão')
                    : Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: state.connections.length,
                          itemBuilder: (context, index) {
                            final connection = state.connections[index];

                            return connection.buildTile();
                          },
                        ),
                      )
              ],
            );
          }
          return Container();
        },
      ),
    );

    return BlocProvider<ConnectionPanelBloc>(
      create: (_) => ConnectionPanelBloc(userData, ConnectionDataSource()),
      child: CustomScaffold(
        floatingActionButton: BlocSelector<ConnectionPanelBloc, ConnectionPanelState, bool>(
          selector: (state) => state is ConnectionPanelReady,
          builder: (selectorCtx, isReady) {
            final bloc = selectorCtx.read<ConnectionPanelBloc>();
            if (isReady) {
              return FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () {
                  showDialog(
                      context: selectorCtx,
                      builder: (_) {
                        return RequestConnectionDialog(onRequested: (code) => bloc.add(ConnectionPanelRequested(code)));
                      });
                },
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        child: BlocBuilder<ConnectionPanelBloc, ConnectionPanelState>(
          builder: (ctx, state) {
            final bloc = ctx.read<ConnectionPanelBloc>();
            if (state is ConnectionPanelInitial) {
              bloc.add(ConnectionPanelStarted());
              return const CircularProgressIndicator();
            } else if (state is ConnectionPanelLoadInProgress) {
              return const CircularProgressIndicator();
            } else if (state is ConnectionPanelReady) {
              return _ReadyScreen(state);
            } else if (state is ConnectionPanelError) {
              return GenericErrorComponent(state.error, onRefresh: () => bloc.add(ConnectionPanelStarted()));
            } else {
              return Column(
                children: [
                  const Text('NoState'),
                  IconButton(
                    onPressed: () => bloc.add(ConnectionPanelStarted()),
                    icon: const Icon(Icons.refresh_outlined),
                  )
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

  final ConnectionPanelReady state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderLine('Conexões', Symbols.partner_exchange),
        const SizedBox(height: 12),
        state.connections.isEmpty
            ? const Text('Nenhuma conexão')
            : Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 10);
                  },
                  itemCount: state.connections.length,
                  itemBuilder: (context, index) {
                    final connection = state.connections[index];

                    return connection.buildTile();
                  },
                ),
              )
      ],
    );
  }
}
