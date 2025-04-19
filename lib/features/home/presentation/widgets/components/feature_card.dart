part of '../../../data/models/feature_data.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard(this.data, {super.key});

  final FeatureData data;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if(data.extraAction != null){
            data.extraAction!();
          }
          if (data.destinationRoute != null) {
            context.pushNamed(data.destinationRoute!);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size.width * 0.29,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(data.name, style: titleMedium, textAlign: TextAlign.center),
              Icon(data.icon, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
