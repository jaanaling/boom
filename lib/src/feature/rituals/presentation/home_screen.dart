import 'package:booms/routes/go_router_config.dart';
import 'package:booms/routes/route_value.dart';
import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/src/core/utils/size_utils.dart';
import 'package:booms/src/core/utils/text_with_border.dart';
import 'package:booms/src/feature/rituals/bloc/user_bloc.dart';
import 'package:booms/ui_kit/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      color: ButtonColors.purple,
                      onPressed: () {
                        context.push(
                            '${RouteValue.home.path}/${RouteValue.achievement.path}');
                      },
                      child: AppIcon(
                        asset: IconProvider.achievement.buildImageUrl(),
                        width: 32,
                        height: 40,
                      ),
                    ),
                    CoinsRow(
                      coins: state.user.coins,
                    ),
                  ],
                ),
              ),
              Spacer(),
              AppButton(
                color: ButtonColors.pink,
                isBig: true,
                onPressed: () {
                  context.push(
                      '${RouteValue.home.path}/${RouteValue.select.path}');
                },
                child: const TextWithBorder('SELECT LEVEL'),
              ),
              const SizedBox(height: 10),
              AppButton(
                color: ButtonColors.orange,
                isBig: true,
                onPressed: () {
                  context.push(
                      '${RouteValue.home.path}/${RouteValue.select.path}/${RouteValue.game.path}',
                      extra: 15);
                },
                child: const TextWithBorder('DAILY'),
              ),
              const SizedBox(height: 30),

              // Блок "Daily Reward! +112" и кнопка CLAIM
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      width: 329,
                      height: 160,
                      decoration: ShapeDecoration(
                        color: Color(0x30000975),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const TextWithBorder(
                            'TODAY REWARD!',
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWithBorder(
                                '+30',
                                fontSize: 53,
                              ),
                              Gap(20),
                              Transform(
                                transform: Matrix4.identity()
                                  ..translate(0.0, 0.0)
                                  ..rotateZ(0.26),
                                child: AppIcon(
                                  asset: IconProvider.coins.buildImageUrl(),
                                  width: 57.88,
                                  height: 67.52,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  AppButton(
                    isLong: state.user.coins > 0,
                    color:  state.user.coins > 0?ButtonColors.grey:ButtonColors.green,
                    onPressed: state.user.coins > 0? null: () {
                      context.read<UserBloc>().add(UserAddCoins(30));
                    },
                    child: const TextWithBorder(
                      'CLAIM',
                      fontSize: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Плашки первого, второго, третьего дня с цифрами и подарками (пример)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          TextWithBorder(
                            '+30',
                            fontSize: 18,
                          ),
                          Gap(10),
                          Transform(
                            transform: Matrix4.identity()
                              ..translate(0.0, 0.0)
                              ..rotateZ(0.26),
                            child: AppIcon(
                              asset: IconProvider.coins.buildImageUrl(),
                              width: 25,
                            ),
                          ),
                        ],
                      ),
                      // Замените на нужный виджет и/или иконку подарка
                      AppIcon(
                        asset: IconProvider.daily.buildImageUrl(),
                        width: 40,
                      ),
                      Text(
                        '1st day',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      AppIcon(
                        asset: IconProvider.gift.buildImageUrl(),
                        width: 40,
                      ),
                      Text(
                        '2nd day',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      AppIcon(
                        asset: IconProvider.gift.buildImageUrl(),
                        width: 40,
                      ),
                      Text(
                        '3rd day',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer()
            ],
          ),
        );
      },
    );
  }
}

class CoinsRow extends StatelessWidget {
  final int coins;
  const CoinsRow({
    required this.coins,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 139,
      decoration: ShapeDecoration(
        color: Color(0x70000344),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                coins.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(
              flex: 1,
            ),
            AppIcon(
              asset: IconProvider.coins.buildImageUrl(),
              width: 48,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }
}
