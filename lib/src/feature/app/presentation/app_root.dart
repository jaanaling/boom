import 'package:booms/src/feature/rituals/bloc/user_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../routes/go_router_config.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(const UserLoadData()),
      child: CupertinoApp.router(
        theme: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFFFF48A0),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              fontFamily: 'Purple',
              fontSize: 37,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0), // Смещение тени
                  color: Color(0x80000000), // Цвет тени с прозрачностью
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        builder: (context, child) {
          return Theme(
            data: ThemeData(
              primaryColor: const Color(0xFFFF48A0),
              primarySwatch: Colors.pink,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(
                  fontFamily: 'Purple',
                  fontSize: 37,
                  color: Colors.white,
                ),
              ),
            ),
            child: child!,
          );
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: buildGoRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
