import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'utils/custom_colors.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() => _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState extends State<ScaffoldWithNestedNavigation> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      /// Quando o usuário aperta no ícone da branch que ele já está, ele é direcionado para a initialLocation da branch
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: CustomColor.bottomBarBg,
        selectedIndex: widget.navigationShell.currentIndex,
        indicatorColor: CustomColor.activeColor,
        destinations: const [
          NavigationDestination(label: 'Contratos', icon: Icon(Symbols.contract_rounded)),
          NavigationDestination(label: 'Home', icon: Icon(Icons.home_outlined)),
          NavigationDestination(label: 'Mensagens', icon: Icon(Icons.message_outlined)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
