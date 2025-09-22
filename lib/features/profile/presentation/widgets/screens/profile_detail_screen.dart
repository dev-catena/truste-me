
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../register/domain/entities/user_info_data.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {

  late UserInfoData personalData;

  @override
  void initState() {
    final userData = context.read<UserDataCubit>();
    var user = userData.getUser;
    personalData = UserInfoData(name: user.fullName, cpf: user.cpf, email: user.email, birthDate: user.birthDate);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
        child: SafeArea(
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  personalData.buildForm(
                    onPersonalDataSet: (value, email, cpf) {
                      //personalData = value;
                      //emailExists = email;
                      //cpfExists = cpf;
                      setState(() {});
                    },
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      //bottom: tabBar,
      title: Text("Atualizar dados", style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
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
        TextButton(
          onPressed: _save,
          child: const Text('SALVAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),),
        ),
        const SizedBox(width: 10),
      ],
      backgroundColor: CustomColor.activeColor,
    );
  }

  Future<void> _save() async {
    // TODO: ...
  }
}

