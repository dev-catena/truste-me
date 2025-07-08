import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/enums/contract_status.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/generic_error_component.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../blocs/contract_detail/contract_detail_bloc.dart';
import '../components/clause_selection_card.dart';
import '../components/contract_specification_widget.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen(this.contract, {super.key});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractDetailBloc(ContractDataSource(), contract),
      child: CustomScaffold(
        child: BlocBuilder<ContractDetailBloc, ContractDetailState>(
          builder: (blocCtx, state) {
            final bloc = blocCtx.read<ContractDetailBloc>();
            if (state is ContractDetailInitial) {
              bloc.add(ContractDetailStarted());
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContractDetailLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContractDetailReady) {
              return _ContractReady(state);
            } else if (state is ContractDetailError) {
              return GenericErrorComponent(state.msg, onRefresh: () => bloc.add(ContractDetailStarted()));
            } else {
              return Column(
                children: [
                  const Text('NoState'),
                  IconButton(
                      onPressed: () => bloc.add(ContractDetailStarted()), icon: const Icon(Icons.refresh_outlined))
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class _ContractReady extends StatelessWidget {
  const _ContractReady(this.state);

  final ContractDetailReady state;

  // bool get canFinish {
  //   final bool allClausesSet = state.contract.clauses.every((element) => element.pendingFor.isEmpty);
  //   final bool allPractices = state.contract.sexualPractices.every((element) => element.pendingFor?.isEmpty ?? true);
  //
  //   return allClausesSet && allPractices;
  // }

  // bool canFinish() {
  //   if (state.contract.clauses.every((element) => element.pendingFor.isNotEmpty)) {
  //     return false;
  //   }
  //   if (state.contract.clauses.every((element) =>
  //   (element.deniedBy.length % 2) == 0 && (element.acceptedBy.length % 2) == 0)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  bool canProceed() {
    final participantsId = [
      ...state.contract.stakeHolders.map((e) => e.id),
      state.contract.contractor.id,
    ];

    final isMainClausesOk = _getPendingClauses(state.contract.clauses, participantsId);
    final isOtherClausesOk =
        _getPendingClauses(state.contract.sexualPractices.map((e) => e.toClause()).toList(), participantsId);

    return isMainClausesOk.isEmpty && isOtherClausesOk.isEmpty;
  }

  List<Clause> _getPendingClauses(List<Clause> clauses, List<int> participantsId) {
    final pending = <Clause>[];

    pending.addAll(clauses.where((element) => !element.isClauseOk(participantsId)));

    return pending;
  }

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final bloc = context.read<ContractDetailBloc>();

    return RefreshIndicator(
      onRefresh: () async => context.read<ContractDetailBloc>().add(ContractDetailStarted()),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeaderLine('Contrato ${state.contract.contractNumber}', Symbols.contract),
            const SizedBox(height: 12),
            state.contract.buildDetailCard(),
            // const SizedBox(height: 12),
            // Text(
            //   'Atividades',
            //   style: titleLarge.copyWith(fontWeight: FontWeight.w600),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 12),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     FeatureData(
            //       name: 'Histórico',
            //       icon: Icons.history,
            //       extraAction: () {
            //         showDialog(
            //           context: context,
            //           builder: (context) {
            //             return const ContractHistoryDialog();
            //           },
            //         );
            //       },
            //     ).buildCard(),
            //     FeatureData(name: 'Download', icon: Symbols.file_save).buildCard(),
            //   ],
            // ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Detalhes',
                  style: titleLarge.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                if (!canProceed())
                  IconButton(
                    onPressed: () {
                      final participantsId = [
                        ...state.contract.stakeHolders.map((e) => e.id),
                        state.contract.contractor.id,
                      ];

                      final pendingClauses = _getPendingClauses(state.contract.clauses, participantsId);
                      final pendingPractices = _getPendingClauses(
                        state.contract.sexualPractices.map((e) => e.toClause()).toList(),
                        participantsId,
                      );

                      final pendingNames = [
                        ...pendingClauses.map((c) => '${c.code} - ${c.name}'),
                        ...pendingPractices.map((p) => '${p.code} - ${p.name}'),
                      ];

                      final message = pendingNames.join('\n');

                      context.showTopSnackBar(
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Pendências:', textAlign: TextAlign.center),
                            Text(message),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber_outlined, color: CustomColor.vividRed),
                  )
              ],
            ),
            const SizedBox(height: 12),
            // if (state.possibleClauses.isNotEmpty || state.contract.clauses.isNotEmpty)
            // TODO: trocar comparação por ID
            if (state.contract.type.id != 2)
              ClauseSelectionCard(
                canEdit: state.contract.status == ContractStatus.pending,
                contractor: state.contract.contractor,
                stakeHolders: state.contract.stakeHolders,
                possibleClauses: state.possibleClauses,
                clausesChosen: state.contract.clauses,
                onClausePicked: (value) => bloc.add(ContractDetailClauseAdded(value)),
                onAcceptOrDeny: (clause, value) => bloc.add(ContractDetailClauseSet(clause, value)),
                onRemove: null,
              ),
            const SizedBox(height: 12),
            if (state.contract.type.id != 1)
              ContractSpecificationWidget(
                canEdit: state.contract.status == ContractStatus.pending,
                type: state.contract.type,
                practicesAvailable: state.possiblePractices,
                initialPractices: state.contract.sexualPractices,
                participants: [state.contract.contractor, ...state.contract.stakeHolders],
                showStatusPerUser: true,
                onPick: (value) => bloc.add(ContractDetailPracticeAdded(value)),
                onRemove: null,
                onAcceptOrDeny: state.contract.status == ContractStatus.pending
                    ? (practice, value) => bloc.add(ContractDetailPracticeSet(practice, value))
                    : null,
                answers: state.contract.answers,
                onQuestionAnswered: (question, answer) =>
                    bloc.add(ContractDetailContractQuestionAnswered(question, answer)),
              ),
            const SizedBox(height: 12),
            // if (state.contract.status == ContractStatus.pending)
            //   FilledButton(
            //     onPressed: () {
            //       if (!canProceed()) return;
            //       bloc.add(ContractDetailContractFinished());
            //     },
            //     style: ButtonStyle(
            //       backgroundColor: WidgetStatePropertyAll(canProceed() ? null : CustomColor.activeGreyed),
            //     ),
            //     child: const Text('Celebrar contrato'),
            //   ),
            if (state.contract.signatures.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('Assinaturas', style: titleMedium),
                    ...List.generate(
                      state.contract.signatures.length,
                      (index) {
                        final acceptance = state.contract.signatures[index];
                        final allParticipants = [...state.contract.stakeHolders, state.contract.contractor];

                        final user = allParticipants.firstWhere((element) => element.id == acceptance.userId);

                        if (acceptance.dateTime != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
                                const SizedBox(width: 10),
                                Text(
                                    '${user.fullName} às ${DateFormat('HH:mm, dd/MM/yyyy', 'pt_BR').format(acceptance.dateTime!)}.'),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.pending_outlined, color: CustomColor.pendingYellow),
                                const SizedBox(width: 10),
                                Text('${user.fullName}: não assinado.'),
                              ],
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              )
            else
              const Text('Contrato ainda não assinado por nenhuma parte'),
            const SizedBox(height: 12),

            if (state.contract.status == ContractStatus.pending)
              FilledButton(
                onPressed: () {
                  if (!canProceed()) return;
                  bloc.add(ContractDetailContractSigned());
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(canProceed() ? null : CustomColor.activeGreyed),
                ),
                child: const Text('Assinar contrato'),
              ),
          ],
        ),
      ),
    );
  }
}
