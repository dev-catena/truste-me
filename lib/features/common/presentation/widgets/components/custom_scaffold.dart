import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../domain/entities/person.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.floatingActionButton,
    this.tabBar,
  });

  final Widget child;
  final Widget? floatingActionButton;
  final TabBar? tabBar;

  @override
  Widget build(BuildContext context) {
    final headlineMedium = Theme.of(context).textTheme.headlineMedium!;

    return Scaffold(
      floatingActionButton: floatingActionButton,
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: AppBar(
        bottom: tabBar,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            Text('TrustMe', style: headlineMedium.copyWith(color: Colors.white)),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              if (GoRouter.of(context).state.name != AppRoutes.profileScreen) {
                context.push(AppRoutes.profileScreen);
              }
            },
            child: CircleAvatar(
              backgroundImage: userLoggedIn.photoPath != null ? NetworkImage(userLoggedIn.photoPath!) : null,
            ),
          ),
          const SizedBox(width: 10),
        ],
        backgroundColor: CustomColor.activeColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
          child: child,
        ),
      ),
    );
  }
}
