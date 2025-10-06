
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../../common/data/data_source/user_data_source.dart';
import '../../../../common/domain/entities/location.dart';
import '../../../../common/domain/entities/user.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/generic_error_component.dart';
import '../../../../register/domain/entities/address_info_data.dart';
import '../../../../register/domain/entities/complemenary_info_data.dart';
import '../../../../register/domain/entities/user_info_data.dart';
import '../../../../register/presentation/widgets/screens/register_screen.dart';
import '../../blocs/profile_detail/profile_detail_bloc.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {

  late UserInfoData personalData;
  late AddressInfoData addressData;
  late ComplementaryInfoData complementaryInfoData;

  //late User userEdition;

  @override
  void initState() {
    final userData = context.read<UserDataCubit>();
    final userEdition = userData.getUser; //.copyWith();

    personalData = UserInfoData(id: userEdition.id, name: userEdition.fullName, cpf: userEdition.cpf, email: userEdition.email, birthDate: userEdition.birthDate);
    addressData = AddressInfoData(isEdition: true, loc: Location(id: userEdition.id, cep: userEdition.cep ?? '', state: userEdition.state ?? '', city: userEdition.city ?? '', neighborhood: userEdition.neighborhood ?? '', street: userEdition.address ?? '', number: userEdition.addressNumber ?? '', complement: userEdition.addressComplement ?? ''));
    complementaryInfoData = ComplementaryInfoData(isEdition: true, userProfession: userEdition.profession, userIncome: IncomeRange.values.firstWhereOrNull( (x) => x.description == userEdition.income ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return BlocProvider(
      create: (_) => ProfileDetailBloc(userData.userDataSource, userData),
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
                      return _buildProfileForm(state.user);
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

  Widget _buildProfileForm(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4,),
        personalData.buildForm(
          onPersonalDataSet: (value, email, cpf) {
            //personalData = value;
            //emailExists = email;
            //cpfExists = cpf;
            personalData = value;
            //setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: addressData.buildForm(onLocationChanged: (Location loc) {
            // ...
            //setState(() {});
            addressData.loc = loc;
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: complementaryInfoData.buildForm(onIncomeSet: (value) {
            // ...
            //setState(() {});
            complementaryInfoData.userIncome = value;
          },
          onProfessionSet: (value) {
            // ...
            //setState(() {});

            complementaryInfoData.userProfession = value;
          }),
        ),

        SizedBox(height: 50,),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      //titleSpacing: 0,
      //bottom: tabBar,
      title: Text('Atualizar dados', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
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
      //     Text('TrustMe', style: headlineMedium.copyWith(color: Colors.white)),
      //   ],
      // ),
      actions: [
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => _save(context),
              child: const Text('SALVAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),),
            );
          }
        ),
        const SizedBox(width: 10),
      ],
      backgroundColor: CustomColor.activeColor,
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!personalData.isValid) {
      context.showSnack(personalData.getWarningMessage());
      return;
    }

    if (!addressData.isValid) {
      context.showSnack(addressData.getWarningMessage());
      return;
    }

    if (!complementaryInfoData.isValid) {
      context.showSnack(complementaryInfoData.getWarningMessage());
      return;
    }

    // Everything is OK, let's update it!

    String? professionValue;

    if(complementaryInfoData.userProfession != null && complementaryInfoData.userProfession!.trim().isNotEmpty) {
      professionValue = complementaryInfoData.userProfession!.trim();
    }

    final userDataUpdated = {
      'email': personalData.email,
      'CPF': personalData.cpf,
      'nome_completo': personalData.name,
      'pais': 'Brasil',
      ...addressData.loc.toModel().toJson(),
      'profissao': professionValue,
      'dt_nascimento': personalData.birthDate.toString(),
      'renda_classe': complementaryInfoData.userIncome?.description,

      // 'password': userPwd,
      // 'password_confirmation': userPwdConfirmation,
    };

    final bloc = context.read<ProfileDetailBloc>();
    bloc.add(ProfileDetailSave(userDataUpdated));
  }
}

