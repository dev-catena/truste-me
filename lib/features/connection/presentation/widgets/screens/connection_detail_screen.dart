import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/extensions/context_extensions.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
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
  late final UserDataCubit userData;
  final List<Seal> seals = [];
  bool loadingSeals = true;

  Future<void> acceptConnection(bool hasAccepted) async {
    acceptInProgress = true;

    try {
      await userData.establishConnection(widget.connection, hasAccepted);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conexão ${hasAccepted ? 'aceita' : 'recusada'}!'),
        ));
        context.pop();
      }
    } on HttpRequestException catch (e, s) {
      context.showSnack('Erro ao estabelecer conexão. ${e.message}');
    } on Exception catch(e, s) {
      context.showSnack('Erro ao estabelecer conexão. ${e.toString()}');
    } finally {
      acceptInProgress = false;
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
                onPressed: () {
                  acceptConnection(false);
                },
                child: const Text('Recusar'),
              ),
              FilledButton(
                onPressed: () {
                  acceptConnection(true);
                },
                child: const Text('Aceitar'),
              ),
            ],
          ),
          // TextButton(
          //   onPressed: () {},
          //   child: const Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.warning_amber_outlined, color: CustomColor.vividRed),
          //       SizedBox(width: 10),
          //       Text(
          //         'Bloquear comunicação',
          //         style: TextStyle(color: CustomColor.vividRed),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    } else if (widget.connection.status == ConnectionStatus.accepted) {
      return OutlinedButton(
        onPressed: () async {

          showDialog(context: context, builder: (BuildContext dialogContext) {
            return AlertDialog(
                title: Text('Desfazer conexão'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Você deseja mesmo desfazer a conexão?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss the dialog
                    },
                  ),
                  TextButton(
                    child: Text('Sim'),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Dismiss the dialog

                      try {
                        await userData.deleteConnection(widget.connection);

                        if (context.mounted) {
                          context.pop();
                        }
                      } on HttpRequestException catch (e, s) {
                        context.showSnack('Não foi possível desfazer a conexão. ${e.message}');
                      } on Exception catch(e, s) {
                        context.showSnack('Não foi possível desfazer a conexão. ${e.toString()}');
                      }
                    },
                  ),
                ],
            );
          });
        },
        child: const Text('Desfazer conexão'),
      );
    } else if (widget.connection.status == ConnectionStatus.cancelled) {
      return OutlinedButton(
        onPressed: () async {
          try {
            await userData.deleteConnection(widget.connection);

            if (context.mounted) {
              context.pop();
            }
          } on HttpRequestException catch (e, s) {
            context.showSnack('Não foi possível cancelar a solicitação. ${e.message}');
          } on Exception catch(e, s) {
            context.showSnack('Não foi possível cancelar a solicitação. ${e.toString()}');
          }
        },
        child: const Text('Cancelar solicitação'),
      );
    } else {
      return const SizedBox();
    }
  }

  bool showSeals() {
    if (widget.connection.status == ConnectionStatus.accepted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    userData = context.read<UserDataCubit>();
    if (showSeals()) {
      userData.userDataSource.getSeals(widget.connection.user).then(
            (value) =>
            setState(() {
              seals.addAll(value);
              loadingSeals = false;
            }),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAvatar: false,
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
              if (showSeals()) loadingSeals ? const CircularProgressIndicator() : SealsBoard(seals, canGetSeal: false),
            ],
          ),
        ),
      ),
    );
  }
}
