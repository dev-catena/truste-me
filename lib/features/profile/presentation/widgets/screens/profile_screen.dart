import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';

import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/main.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/connection/presentation/widgets/components/seals_board.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  final bool showEditButton;
  final bool showSealsInfo;
  final bool showPrivacyPoliceLink;
  final bool showDeleteAccountLink;
  final bool showChildSafetyLink;

  const ProfileScreen({
    super.key,
    this.showEditButton = true,
    this.showSealsInfo = true,
    this.showPrivacyPoliceLink = false,
    this.showDeleteAccountLink = false,
    this.showChildSafetyLink = false,
  });

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<UserDataCubit, UserDataState>(
      builder: (context, state) {

        if (state is UserDataReady) {
          return CustomScaffold(
            showAvatar: false,
            child: RefreshIndicator(
              onRefresh: () => context.read<UserDataCubit>().initialize(state.user),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    state.user.buildSummaryCard(
                      isLoggedUser: true,
                      showEditButton: showEditButton,
                    ),
                    Visibility(
                      visible: showSealsInfo,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SealsBoard(state.user.sealsObtained, canGetSeal: true),
                      ),
                    ),

                    Visibility(
                      visible: showPrivacyPoliceLink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () => launchUrl(Uri.parse('https://rdd2.github.io/true-connect/politica-privacidade.html')),
                          child: Card(
                            child: ListTile(
                              title: const Text('Política de Privacidade'),
                              leading: const Icon(Icons.privacy_tip_outlined,
                            ),
                          ),
                                              ),
                        ),
                      ),
                    ),

                    Visibility(
                      visible: showPrivacyPoliceLink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () => launchUrl(Uri.parse('https://rdd2.github.io/true-connect/exclusao-conta.html')),
                          child: Card(
                            child: ListTile(
                              title: const Text('Exclusão de conta'),
                              leading: const Icon(Icons.delete_outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Visibility(
                      visible: showPrivacyPoliceLink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () {
                             context.push(AppRoutes.childSafetyScreen);
                          },
                          child: Card(
                            child: ListTile(
                              title: const Text('Segurança infantil'),
                              leading: const Icon(Icons.child_care_outlined,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),



                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Sair'),
                      leading: const Icon(Icons.logout_outlined, color: CustomColor.vividRed),
                      onTap: () {
                        TrustMeApp.logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
