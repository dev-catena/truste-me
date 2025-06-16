part of '../../../domain/entities/contract.dart';

class ContractDetailSummaryCard extends StatelessWidget {
  const ContractDetailSummaryCard(this.contract, {super.key});

  final Contract contract;

  String parsedData() {
    String date = 'Sem periodo de vigência';
    if (contract.startDate != null && contract.endDate != null) {
      String parse() {
        final stDt = contract.startDate!;
        final endDt = contract.endDate!;

        final startDt = '${stDt.day.toString().padLeft(2, '0')}/${stDt.month.toString().padLeft(2, '0')}/${stDt.year}';
        final edDt = '${endDt.day.toString().padLeft(2, '0')}/${endDt.month.toString().padLeft(2, '0')}/${endDt.year}';
        return '$startDt - $edDt';
      }

      date = parse();
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Contratante: ${contract.contractor?.fullName}', textAlign: TextAlign.center),
          Text('CPF: ${contract.contractor?.cpf}', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ...List.generate(
            contract.stakeHolders.length,
            (index) {
              return Column(
                children: [
                  Text('Parte interessada: ${contract.stakeHolders[index].fullName}', textAlign: TextAlign.center),
                  Text('CPF: ${contract.stakeHolders[index].cpf}', textAlign: TextAlign.center),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const Text('Período de vigência'),
          Text(parsedData()),
        ],
      ),
    );
  }
}
