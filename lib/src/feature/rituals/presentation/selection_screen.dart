import 'package:booms/routes/route_value.dart';
import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/src/core/utils/size_utils.dart';
import 'package:booms/src/core/utils/text_with_border.dart';
import 'package:booms/src/feature/rituals/bloc/user_bloc.dart';
import 'package:booms/src/feature/rituals/presentation/home_screen.dart';
import 'package:booms/ui_kit/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        width: 58,
                        height: 58,
                        onPressed: () {
                          context.pop();
                        },
                        child: AppIcon(
                          asset: IconProvider.arrow.buildImageUrl(),
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
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: List.generate(250, (index) {
                        return AppButton(
                          width: getWidth(context, percent: 0.3),
                          height: getWidth(context, percent: 0.3),
                          onPressed: () {
                            if (state.user.levels
                                    .map((toElement) => toElement.id)
                                    .toList()
                                    .contains(index + 1) ||
                                index == state.user.levels.length)
                              context.push(
                                  "${RouteValue.home.path}/${RouteValue.select.path}/${RouteValue.game.path}",
                                  extra: index);
                            else if (index % 10 == 0) {
                              _showDialog(context, false);
                            } else {
                              _showDialog(context, true);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (state.user.levels
                                      .map((toElement) => toElement.id)
                                      .toList()
                                      .contains(index + 1) ||
                                  index == state.user.levels.length)
                                Column(
                                  children: [
                                    TextWithBorder(
                                      (index + 1).toString(),
                                      fontSize: 61,
                                      fontFamily: "One",
                                    ),
                                    Star(
                                      score: index == state.user.levels.length
                                          ? 0
                                          : state.user.levels
                                              .firstWhere((element) =>
                                                  element.id == index + 1)
                                              .score,
                                    )
                                  ],
                                )
                              else if (index % 10 == 0)
                                TextWithBorder(
                                  "?",
                                  fontSize: 88,
                                  fontFamily: "One",
                                )
                              else
                                AppIcon(
                                  asset: IconProvider.lock.buildImageUrl(),
                                  width: 71,
                                  height: 76,
                                )
                            ],
                          ),
                        );
                      }),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showDialog(BuildContext context, bool lock) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: 300,
          width: 450,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 250,
                width: 450,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(IconProvider.panel.buildImageUrl()),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: Column(
                    children: [
                      Text(
                        lock
                            ? 'Go through the previous level'
                            : "Pass the previous levels by 5 stars, and then you'll unlock a miracle!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Purple',
                          fontSize: lock? 27:22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppButton(
                  width: getWidth(context, percent: 0.3),
                  height: 59,
                  onPressed: () {
                    context.pop();
                  },
                  child: const TextWithBorder(
                    'OK',
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class Star extends StatelessWidget {
  final int score;
  final double size;

  const Star({Key? key, required this.score, this.size = 28.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Размер звезды
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Для выравнивания по центру
      children: [
        Transform(
          transform: Matrix4.identity()
            ..rotateZ(0.0), // Без вращения для первого элемента
          child: AppIcon(
            asset: IconProvider.star.buildImageUrl(),
            width: size - 13.27,
            height: size - 13.27,
            color: score > 0 ? null : Colors.black.withOpacity(0.5),
            blendMode: BlendMode.srcATop,
          ),
        ),
        Transform(
          transform: Matrix4.identity()
            ..rotateZ(0.05), // Меньшее вращение для второго элемента
          child: AppIcon(
            asset: IconProvider.star.buildImageUrl(),
            width: size - 6.19,
            height: size - 6.19,
            color: score > 1 ? null : Colors.black.withOpacity(0.5),
            blendMode: BlendMode.srcATop,
          ),
        ),
        AppIcon(
          asset: IconProvider.star.buildImageUrl(),
          width: size,
          height: size,
          color: score > 2 ? null : Colors.black.withOpacity(0.5),
          blendMode: BlendMode.srcATop,
        ),
        Transform(
          transform: Matrix4.identity()
            ..rotateZ(-0.05), // Меньше вращения для четвертого элемента
          child: AppIcon(
            asset: IconProvider.star.buildImageUrl(),
            width: size - 6.19,
            height: size - 6.19,
            color: score > 3 ? null : Colors.black.withOpacity(0.5),
            blendMode: BlendMode.srcATop,
          ),
        ),
        Transform(
          transform: Matrix4.identity()
            ..rotateZ(0.0), // Без вращения для пятого элемента
          child: AppIcon(
            asset: IconProvider.star.buildImageUrl(),
            width: size - 13.27,
            height: size - 13.27,
            color: score > 4 ? null : Colors.black.withOpacity(0.5),
            blendMode: BlendMode.srcATop,
          ),
        ),
      ],
    );
  }
}
