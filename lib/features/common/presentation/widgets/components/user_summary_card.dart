import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes.dart';
import '../../../../../core/utils/date_parser.dart';
import '../../../domain/entities/user.dart';

class UserSummaryCard extends StatelessWidget {
  final User user;
  final bool isLoggedUser;
  final bool showEditButton;

  const UserSummaryCard(this.user, {super.key, required this.isLoggedUser, this.showEditButton = true});

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 50),
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40), // Space f
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
                // Space for the avatar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(user.fullName, style: titleLarge.copyWith(fontWeight: FontWeight.w600))),
                    Center(child: Text(user.connectionCode, style: titleMedium.copyWith(fontWeight: FontWeight.w600))),
                    const SizedBox(height: 10),
                    const Text('Informações públicas', style: TextStyle(color: Colors.black54)),
                    Text('${user.age} anos'),
                    Text('${user.state}, ${user.country}'),
                    Text('${user.profession}'),
                    const Spacer(),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: isLoggedUser && showEditButton,
                            child: FilledButton(
                              onPressed: () {
                                context.pushNamed(AppRoutes.profileDetailScreen);
                              },
                              // style: ButtonStyle(
                              //   backgroundColor:
                              //       WidgetStatePropertyAll(!validateInfo() ? CustomColor.activeColor.withAlpha(100) : null),
                              // ),
                              child: Text('Editar'),
                            ),
                          ),
                          Text(
                            'Perfil criado ${DateParser.formatDate(user.memberSince.toLocal(), showYear: true, prefix: "em ")}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: -30, child: user.buildAvatar(60, true)),
          ],
        ),
      ],
    );
  }
}
