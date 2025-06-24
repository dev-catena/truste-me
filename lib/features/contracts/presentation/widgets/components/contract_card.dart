part of '../../../domain/entities/contract.dart';

class ContractCard extends StatelessWidget {
  const ContractCard(this.contract, {super.key});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    // final formatedDate = DateParser.formatDate(contract.status.since, true, true);
    final List<User> contWithStakeholders = [contract.contractor!, ...contract.stakeHolders];

    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.contractDetailScreen, extra: contract),
      child: Container(
        width: size.width * 0.4,
        height: 190,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(3, 2),
              blurRadius: 5,
            ),
          ],
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: contract.status.color),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Stack(
              children: [
                Text('Contrato ${contract.contractNumber}', style: titleMedium, textAlign: TextAlign.center),

              ],
            ),
            // Text(contract.stakeHolder!.fullName, textAlign: TextAlign.center),
            Text(contract.type.description, textAlign: TextAlign.center),
            const Spacer(),
            ...List.generate(
              contWithStakeholders.length,
              (index) {
                final user = contWithStakeholders[index];

                return Text(user.fullName);
              },
            ),
            const Spacer(),
            const Text('Status:', textAlign: TextAlign.center),
            // Text('$formatedDate.', textAlign: TextAlign.center),
            Text(
              contract.status.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
