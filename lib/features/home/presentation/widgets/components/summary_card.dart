import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard(this.data, {super.key});

  final SummaryData data;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final headlineMedium = Theme.of(context).textTheme.headlineMedium!;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.29,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(data.description, style: const TextStyle(color: Colors.black54)),
          ),
          Text('${data.quantity}', style: headlineMedium),
        ],
      ),
    );
  }
}

class SummaryData {
  final String description;
  final int quantity;

  const SummaryData(this.description, this.quantity);

  SummaryCard buildCard(){
    return SummaryCard(this);
  }
}