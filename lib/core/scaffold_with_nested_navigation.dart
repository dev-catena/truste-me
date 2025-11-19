import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/home/presentation/blocs/home_bloc.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell}) : super(key: key);

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDataCubit, UserDataState>(
      listener: (context, state) {
        if (state is UserDataReady && state.event is SealRequestResult) {
          final event = state.event as SealRequestResult;
          context.showSnack(event.message);
          context.read<UserDataCubit>().clearEvent();
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Only show the navigation bar when the HomeBloc is in the ready state.
            if (state is HomeReady) {
              return NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                indicatorColor: CustomColor.activeColor,
                destinations: const [
                  NavigationDestination(label: 'Contratos', icon: Icon(Symbols.list_alt_rounded)),
                  NavigationDestination(label: 'Home', icon: Icon(Icons.home_outlined)),
                  NavigationDestination(label: 'Notificações', icon: Icon(Icons.notifications_active_outlined)),
                ],
                onDestinationSelected: (index) {
                  if (index == 2) {
                    context.showSnack('Em construção...');
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _goBranch(index);
                  }
                },
              );
            }
            // While loading or in an error state, show nothing.
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
