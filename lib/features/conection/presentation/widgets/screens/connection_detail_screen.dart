import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/utils/date_parser.dart';
import '../../../../common/domain/entities/seal.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../domain/entities/connection.dart';
import '../components/seals_board.dart';

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
    await userData.establishConnection(widget.connection, hasAccepted);
    acceptInProgress = false;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Conexão ${hasAccepted ? 'aceita' : 'recusada'}!'),
      ));
      context.pop();
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
          await userData.deleteConnection(widget.connection);

          if (context.mounted) {
            context.pop();
          }
        },
        child: const Text('Desfazer conexão'),
      );
    } else if (widget.connection.status == ConnectionStatus.cancelled) {
      return OutlinedButton(
        onPressed: () async {
          await userData.deleteConnection(widget.connection);

          if (context.mounted) {
            context.pop();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.connection.user.buildSummaryCard(),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.6,
              child: Text(
                'Conexão ${widget.connection.status.description.toLowerCase()}(a) desde ${DateParser.formatDate(
                    widget.connection.since, true)}.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            getAcceptButton(),
            const SizedBox(height: 8),
            if (showSeals()) loadingSeals ? const CircularProgressIndicator() : SealsBoard(seals, canGetSeal: false),
          ],
        ),
      ),
    );
  }
}
