import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_selectable_tile.dart';
import '../../../../common/presentation/widgets/components/start_end_datepicker.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../../conection/domain/entities/connection.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_type.dart';

class NewContractHeader extends StatelessWidget {
  const NewContractHeader(
    this.connections, {
    this.currentStakeHolder,
    this.currentType,
    required this.onStakeHolderSelected,
    required this.onTypeSelected,
    super.key,
  });

  final List<Connection> connections;
  final ValueChanged<Person> onStakeHolderSelected;
  final ValueChanged<ContractType> onTypeSelected;

  final Person? currentStakeHolder;
  final ContractType? currentType;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final List<Person> personList = [];
    final appData = context.read<AppDataCubit>();

    for (final ele in connections.where((element) => element.status == ConnectionStatus.accepted)) {
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
            title: currentStakeHolder?.fullName ?? 'Selecione uma pessoa',
            isActive: currentStakeHolder != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleSelectDialog<Person>(
                    title: 'Selecione a parte interessada',
                    options: personList,
                    getName: (option) => option.fullName,
                    onChoose: onStakeHolderSelected,
                    optionSelected: currentStakeHolder,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Tipo de contrato', style: titleMedium),
          const SizedBox(height: 6),
          CustomSelectableTile(
            title: currentType?.description ?? 'Selecione um tipo',
            isActive: currentType != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleSelectDialog<ContractType>(
                    title: 'Selecione a parte interessada',
                    options: appData.getContractTypes,
                    getName: (option) => option.description,
                    // onChoose: onTypeSelected,
                    // optionSelected: currentType,
                    onChoose: onTypeSelected,
                    optionSelected: currentType,
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
