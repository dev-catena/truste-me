import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/core/utils/date_parser.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/connection/domain/entities/connection.dart';
import 'package:trustme/features/connection/presentation/widgets/components/seals_board.dart';

class ConnectionDetailScreen extends StatefulWidget {
  const ConnectionDetailScreen(this.connection, {super.key});

  final Connection connection;

  @override
  State<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends State<ConnectionDetailScreen> {
  bool acceptInProgress = false;
  bool deleteInProgress = false;
  late final UserDataCubit userData;
  final List<Seal> seals = [];
  bool loadingSeals = true;

  Future<void> acceptConnection(bool hasAccepted) async {
    setState(() {
      acceptInProgress = true;
    });

    try {
      await userData.establishConnection(widget.connection, hasAccepted);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conexão ${hasAccepted ? 'aceita' : 'recusada'}!'),
        ));
        context.pop();
      }
    } on HttpRequestException catch (e) {
      if(context.mounted) context.showSnack('Erro ao estabelecer conexão. ${e.message}');
    } on Exception catch (e) {
      if(context.mounted) context.showSnack('Erro ao estabelecer conexão. ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          acceptInProgress = false;
        });
      }
    }
  }

  Widget getAcceptButton() {
    if (widget.connection.status == ConnectionStatus.pending) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          acceptInProgress
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () => acceptConnection(false),
                      child: const Text('Recusar'),
                    ),
                    FilledButton(
                      onPressed: () => acceptConnection(true),
                      child: const Text('Aceitar'),
                    ),
                  ],
                ),
        ],
      );
    } else if (widget.connection.status == ConnectionStatus.accepted) {
      return OutlinedButton(
        onPressed: deleteInProgress
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Desfazer conexão'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Você deseja mesmo desfazer a conexão?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Sim'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() {
                              deleteInProgress = true;
                            });
                            userData.deleteConnection(widget.connection);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
        child: deleteInProgress
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
            : const Text('Desfazer conexão'),
      );
    } else if (widget.connection.status == ConnectionStatus.cancelled) {
      return OutlinedButton(
        onPressed: deleteInProgress
            ? null
            : () {
                setState(() {
                  deleteInProgress = true;
                });
                userData.deleteConnection(widget.connection);
              },
        child: deleteInProgress
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
            : const Text('Cancelar solicitação'),
      );
    } else {
      return const SizedBox();
    }
  }

  bool showSeals() {
    return widget.connection.status == ConnectionStatus.accepted;
  }

  @override
  void initState() {
    super.initState();
    userData = context.read<UserDataCubit>();
    if (showSeals()) {
      userData.userDataSource.getSeals(widget.connection.user).then(
        (value) {
          if (mounted) {
            setState(() {
              seals.addAll(value);
              loadingSeals = false;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAvatar: false,
      child: BlocListener<UserDataCubit, UserDataState>(
        listener: (context, state) {
          if (state is UserDataReady && state.event is ConnectionRequestResult) {
            final event = state.event as ConnectionRequestResult;
            if (deleteInProgress) {
              setState(() {
                deleteInProgress = false;
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(event.message)));
              }

              if (event.isSuccess && context.mounted) {
                context.pop();
              }
              userData.clearEvent();
            }
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.connection.user.buildSummaryCard(isLoggedUser: false, showEditButton: false),
                const SizedBox(height: 16),
                Text(
                  'Conexão: ${widget.connection.status.description} desde ${DateParser.formatDate(widget.connection.since.toLocal(), showYear: true)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                getAcceptButton(),
                const SizedBox(height: 16),
                if (showSeals())
                  loadingSeals
                      ? const CircularProgressIndicator()
                      : SealsBoard(seals, canGetSeal: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
