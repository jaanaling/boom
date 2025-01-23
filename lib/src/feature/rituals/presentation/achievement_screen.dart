import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/src/core/utils/size_utils.dart';
import 'package:booms/src/core/utils/text_with_border.dart';
import 'package:booms/src/feature/rituals/bloc/user_bloc.dart';
import 'package:booms/ui_kit/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  String text = "";
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
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
                          Spacer(),
                          TextWithBorder('Achievements'),
                          Spacer(
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children:
                          List.generate(state.achievements.length, (index) {
                        return AppButton(
                          width: getWidth(context, percent: 0.3),
                          height: getWidth(context, percent: 0.3),
                          isGreen: state.user.achievements.contains(state.achievements[index].id),
                          onPressed: () {
                            setState(() {
                              text = state.achievements[index].description;
                            });
                          },
                          child: Center(
                            child: TextWithBorder(
                              state.achievements[index].title,
                              fontSize: 18,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ),
                    if(text.isNotEmpty)
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        width: getWidth(context, percent: 1),
                        child: Container(
                          color: Colors.white.withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: TextWithBorder(text, fontSize: 32,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(text.isNotEmpty)
            SizedBox(
             width: getWidth(context, percent: 1),
              child: Container(
                color: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  child: TextWithBorder(text, fontSize: 32,),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
