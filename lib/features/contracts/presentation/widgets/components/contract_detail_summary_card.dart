part of '../../../domain/entities/contract.dart';

class ContractDetailSummaryCard extends StatelessWidget {
  const ContractDetailSummaryCard(this.contract, {super.key});

  final Contract contract;

  // String parsedData() {
  //   String date = 'Sem periodo de vigência';
  //   if (contract.startDate != null && contract.endDate != null) {
  //     String parse() {
  //       final stDt = contract.startDate!;
  //       final endDt = contract.endDate!;
  //
  //       final startDt = '${stDt.day.toString().padLeft(2, '0')}/${stDt.month.toString().padLeft(2, '0')}/${stDt.year}';
  //       final edDt = '${endDt.day.toString().padLeft(2, '0')}/${endDt.month.toString().padLeft(2, '0')}/${endDt.year}';
  //       return '$startDt - $edDt';
  //     }
  //
  //     date = parse();
  //   }
  //   return date;
  // }

  Text getTimeLeft(TextStyle style) {
    final difference = contract.endDt.difference(DateTime.now());
    if (difference.isNegative) {
      return Text('Encerrado', style: style);
    }

    final String timeRemaining;
    if (contract.status == ContractStatus.active) {
      if (difference.inHours <= 1) {
        timeRemaining = '${difference.inMinutes}m';
      } else {
        timeRemaining = '${difference.inHours}h';
      }
    } else if (contract.status == ContractStatus.pending) {
      timeRemaining = '${difference.inMinutes}m';
    } else {
      timeRemaining = '0';
    }

    return Text(timeRemaining, style: style);
  }

  String getTimeLeftLabel() {
    final String message;
    if (contract.status == ContractStatus.active) {
      message = 'Tempo restante';
    } else if (contract.status == ContractStatus.pending) {
      message = 'Tempo restante para efetivação﹡';
    } else {
      message = '';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Tipo de contrato:\n${contract.type.description}', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Contratante: ${contract.contractor != userLoggedIn ? contract.contractor.obfuscateName() : contract.contractor.fullName}',
            textAlign: TextAlign.center,
          ),
          Text(
            'CPF: ${contract.contractor != userLoggedIn ? contract.contractor.obfuscateCpf() : contract.contractor.cpf}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...List.generate(
            contract.stakeHolders.length,
            (index) {
              final user = contract.stakeHolders[index];

              if (user != userLoggedIn) {
                return Column(
                  children: [
                    Text('Parte interessada: ${user.obfuscateName()}', textAlign: TextAlign.center),
                    Text('CPF: ${user.obfuscateCpf()}', textAlign: TextAlign.center),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Text('Parte interessada: ${contract.stakeHolders[index].fullName}', textAlign: TextAlign.center),
                    Text('CPF: ${contract.stakeHolders[index].cpf}', textAlign: TextAlign.center),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 12),
          const Text('Status atual:', textAlign: TextAlign.center),
          Text(
            contract.status.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (contract.status == ContractStatus.active || contract.status == ContractStatus.pending)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (contract.status == ContractStatus.active)
                  Column(
                    children: [
                      const Text('Duração do contrato', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${contract.duration} ${contract.duration == 1 ? 'hora' : 'horas'}',
                        style: titleLarge,
                      ),
                    ],
                  ),
                Column(
                  children: [
                    Text(getTimeLeftLabel(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    getTimeLeft(titleLarge),
                  ],
                ),
              ],
            ),
          if (contract.status == ContractStatus.pending)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '﹡Se o contrato não for celebrado neste período, ele será automaticamente anulado',
                textAlign: TextAlign.justify,
              ),
            )
        ],
      ),
    );
  }
}
