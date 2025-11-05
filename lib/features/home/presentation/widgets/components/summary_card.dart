import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final SummaryData data;
  final VoidCallback onTap;

  const SummaryCard(this.data, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final headlineMedium = Theme.of(context).textTheme.headlineMedium!;
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size.width * 0.30,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                //padding: const EdgeInsets.only(left: 8),
                child: Text(data.description, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${data.quantity}', style: (data.emphasizeQuantity && data.quantity > 0) ? headlineMedium.copyWith(color: Colors.redAccent) : headlineMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryData {
  final String description;
  final int quantity;
  final VoidCallback onTap;
  final bool emphasizeQuantity;

  const SummaryData(this.description, this.quantity, {this.emphasizeQuantity = false, required this.onTap});

  SummaryCard buildCard(){
    return SummaryCard(this, onTap: onTap,);
  }
}