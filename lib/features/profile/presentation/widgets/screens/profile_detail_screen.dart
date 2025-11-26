import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/common/presentation/widgets/components/generic_error_component.dart';
import 'package:trustme/features/profile/presentation/blocs/profile_detail/profile_detail_bloc.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return BlocProvider(
      create: (_) => ProfileDetailBloc(userData.userDataSource, userData)..add(ProfileDetailStarted()),
      child: Scaffold(
        backgroundColor: CustomColor.backgroundPrimaryColor,
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
          child: SafeArea(
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: BlocConsumer<ProfileDetailBloc, ProfileDetailState>(
                  listener: (blocCtx, state) {
                    if(state is ProfileDetailReady) {
                      final bloc = blocCtx.read<ProfileDetailBloc>();

                      if (state.message != null && state.message!.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message!),
                            //behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Clear message and state
                        bloc.add(ProfileDetailStarted());
                      }
                    }
                  },
                  builder: (blocCtx, state) {
                    final bloc = blocCtx.read<ProfileDetailBloc>();
                    if (state is ProfileDetailInitial) {
                      bloc.add(ProfileDetailStarted());
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProfileDetailLoadInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProfileDetailReady) {
                      return _buildProfileForm(blocCtx, state);
                    } else if (state is ProfileDetailError) {
                      return GenericErrorComponent(state.msg, onRefresh: () => bloc.add(ProfileDetailStarted()));
                    } else {
                      return Column(
                        children: [
                          const Text('NoState'),
                          IconButton(
                              onPressed: () => bloc.add(ProfileDetailStarted()),
                              icon: const Icon(Icons.refresh_outlined))
                        ],
                      );
                    }
                  }
                ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, ProfileDetailReady state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4,),
        state.personalData.buildForm(
          onPersonalDataSet: (value, email, cpf) {
            final currentState = context.read<ProfileDetailBloc>().state as ProfileDetailReady;

            final newPersonalData = currentState.personalData.copyWith(
              name: value.name,
              email: value.email,
              cpf: value.cpf,
              birthDate: value.birthDate,
            );

            context.read<ProfileDetailBloc>().add(PersonalDataChanged(newPersonalData));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: state.addressData.buildForm(onLocationChanged: (loc) {
            final currentState = context.read<ProfileDetailBloc>().state as ProfileDetailReady;
            final newAddressData = currentState.addressData.copyWith(loc: () => loc);
            context.read<ProfileDetailBloc>().add(AddressDataChanged(newAddressData));
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: state.complementaryInfoData.buildForm(
            onIncomeSet: (value) {
              final currentState = context.read<ProfileDetailBloc>().state as ProfileDetailReady;
              final newCompData = currentState.complementaryInfoData.copyWith(userIncome: () => value);
              context.read<ProfileDetailBloc>().add(ComplementaryDataChanged(newCompData));
            },
            onProfessionSet: (value) {
              final currentState = context.read<ProfileDetailBloc>().state as ProfileDetailReady;
              final newCompData = currentState.complementaryInfoData.copyWith(userProfession: value);
              context.read<ProfileDetailBloc>().add(ComplementaryDataChanged(newCompData));
            },
          ),
        ),

        SizedBox(height: 50,),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      //titleSpacing: 0,
      //bottom: tabBar,
      title: Text('Atualizar dados',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     const Padding(
      //       padding: EdgeInsets.only(right: 20),
      //       child: Icon(
      //         Icons.shield_outlined,
      //         color: Colors.white,
      //         size: 40,
      //       ),
      //     ),
      //     Text(GlobalVariables.DEF_APP_NAME, style: headlineMedium.copyWith(color: Colors.white)),
      //   ],
      // ),
      actions: [
        BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
          builder: (context, state) {
            bool isSaving = (state is ProfileDetailReady && state.isSaving);
            return TextButton(
              onPressed: isSaving ? null : () => context.read<ProfileDetailBloc>().add(ProfileDetailSave()),
              child: isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'SALVAR',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
      backgroundColor: CustomColor.primaryColor,
    );
  }
}

