part of '../../../domain/entities/contract.dart';

class ContractCard extends StatelessWidget {
  const ContractCard(this.contract, {super.key, required this.onExpire});

  final Contract contract;
  final void Function(Contract contract) onExpire;

  @override
  Widget build(BuildContext context) {
    final isExpired = contract.endDt.difference(DateTime.now()).isNegative;

    final size = MediaQuery.of(context).size;
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    final stakeholders = [contract.contractor, ...contract.stakeHolders];

    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.contractDetailScreen, extra: contract),
      child: Container(
        width: size.width * 0.4,
        height: 190,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(3, 2), blurRadius: 5)],
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: contract.status.color),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text('Contrato ${contract.contractNumber}', style: titleMedium, textAlign: TextAlign.center),
            Text(contract.type.description, textAlign: TextAlign.center),
            const Spacer(),
            ...stakeholders.map((user) => Text(user.fullName != userLoggedIn.fullName ? user.obfuscateName() : user.fullName)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Status:', textAlign: TextAlign.center),
                    Text(contract.status.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                if ((contract.status == ContractStatus.active || contract.status == ContractStatus.pending) && !isExpired)
                  Column(
                    children: [
                      Icon(Icons.hourglass_top_outlined, color: CustomColor.activeGreyed.withAlpha(100)),
                      TimeLeftTicker(contract: contract, textStyle: titleMedium, onExpire: onExpire),
                      // TimeLeftTicker(contract: contract, textStyle: titleMedium, onExpire: onExpire),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
