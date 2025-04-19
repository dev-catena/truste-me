import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_selectable_tile.dart';
import '../../../../common/presentation/widgets/components/start_end_datepicker.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../domain/entities/contract.dart';
import '../../blocs/new_contract/new_contract_bloc.dart';

class NewContractHeader extends StatelessWidget {
  const NewContractHeader(this.state, {super.key});

  final NewContractReady state;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final List<Person> personList = [];
    final bloc = context.read<NewContractBloc>();

    for (final ele in state.acceptedConnections) {
      personList.add(ele.user);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Parte interessada', style: titleMedium),
          const SizedBox(height: 6),
          CustomSelectableTile(
            title: state.stakeHolderSelected?.fullName ?? 'Selecione uma pessoa',
            isActive: state.stakeHolderSelected != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleSelectDialog<Person>(
                    title: 'Selecione a parte interessada',
                    options: personList,
                    getName: (option) => option.fullName,
                    onChoose: (value) => bloc.add(NewContractStakeHolderSelected(value)),
                    optionSelected: state.stakeHolderSelected,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Tipo de contrato', style: titleMedium),
          const SizedBox(height: 6),
          CustomSelectableTile(
            title: state.contractTypeSelected?.description ?? 'Selecione um tipo',
            isActive: state.contractTypeSelected != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleSelectDialog<ContractType>(
                    title: 'Selecione a parte interessada',
                    options: ContractType.values,
                    getName: (option) => option.description,
                    onChoose: (value) => bloc.add(NewContractTypeSelected(value)),
                    optionSelected: state.contractTypeSelected,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Período de vigência', style: titleMedium),
          const SizedBox(height: 6),
          StartEndDatepicker(
            onDatePicked: (initialDate, endDate) {},
          ),
        ],
      ),
    );
  }
}