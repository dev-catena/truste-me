import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part '../../presentation/widgets/components/feature_card.dart';

class FeatureData {
  final String name;
  final IconData icon;
  final void Function()? extraAction;
  final String? destinationRoute;

  FeatureData({
    required this.name,
    required this.icon,
    this.extraAction,
    this.destinationRoute,
  });

  FeatureCard buildCard() {
    return FeatureCard(this);
  }
}
