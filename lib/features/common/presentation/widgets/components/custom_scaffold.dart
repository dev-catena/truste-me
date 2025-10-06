import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/core/utils/custom_colors.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.floatingActionButton,
    this.tabBar,
    this.showAvatar = true,
  });

  final Widget child;
  final Widget? floatingActionButton;
  final TabBar? tabBar;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final headlineMedium = Theme.of(context).textTheme.headlineMedium!;
    final userData = context.read<UserDataCubit>();

    return Scaffold(
      floatingActionButton: floatingActionButton,
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: AppBar(
        //titleSpacing: 0,
        bottom: tabBar,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(right: 8),
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
          Visibility(
            visible: showAvatar,
            child: InkWell(
              onTap: () {
                if (GoRouter.of(context).state.name != AppRoutes.profileScreen) {
                  context.pushNamed(AppRoutes.profileScreen, extra: { 'showEditButton': true, 'showSealsInfo': true });
                }
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: CustomColor.activeColor, size: 30,),
                // backgroundImage: userData.getUser.photoPath != null ? NetworkImage(userData.getUser.photoPath!) : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
