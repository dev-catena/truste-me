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
          Text('Parte interessada: ${contract.stakeHolder!.fullName}'),
          Text('CPF: ${contract.stakeHolder!.cpf}'),
          const SizedBox(height: 20),
          const Text('Período de vigência'),
          Text(parsedData()),
        ],
      ),
    );
  }
}