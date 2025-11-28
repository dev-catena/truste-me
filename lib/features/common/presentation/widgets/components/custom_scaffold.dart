import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/global/global_variables.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/home/presentation/blocs/home_bloc.dart';

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

    return Scaffold(
      floatingActionButton: floatingActionButton,
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: AppBar(
        //titleSpacing: 0,
        bottom: tabBar,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if(!GlobalVariables.DEF_USE_APP_LOGO_ON_APPBAR)
            Container(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            if(GlobalVariables.DEF_USE_APP_LOGO_ON_APPBAR)
              Container(
                height: 50,
                width: 50,
                padding: EdgeInsets.only(right: 8),
                child: Image.asset('assets/imgs/trustme-logo-white.png'),
              ),
            Text('${GlobalVariables.DEF_APP_NAME}${GlobalVariables.DEF_USE_DEV_ENVIRONMENT ? ' - HML' : ''}', style: headlineMedium.copyWith(color: Colors.white)),
          ],
        ),
        actions: [
          Visibility(
            visible: showAvatar,
            child: InkWell(
              onTap: () {
                final homeState = context.read<HomeBloc>().state;
                if (homeState is HomeReady) {
                  if (GoRouter.of(context).routerDelegate.currentConfiguration.fullPath != AppRoutes.profileScreen) {
                    context.pushNamed(AppRoutes.profileScreen, extra: {'showEditButton': true, 'showSealsInfo': false});
                  }
                } else {
                  context.showSnack(homeState is HomeError ? 'Erro ao carregar os dados. Tente carregá-los' : 'Aguarde o carregamento dos dados...');
                }
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: CustomColor.primaryColor, size: 30,),
                // backgroundImage: userData.getUser.photoPath != null ? NetworkImage(userData.getUser.photoPath!) : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: CustomColor.primaryColor,
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
