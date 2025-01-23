import 'package:booms/src/feature/rituals/presentation/achievement_screen.dart';
import 'package:booms/src/feature/rituals/presentation/game_screen.dart';
import 'package:booms/src/feature/rituals/presentation/home_screen.dart';
import 'package:booms/src/feature/rituals/presentation/selection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../src/feature/splash/presentation/screens/splash_screen.dart';
import 'root_navigation_screen.dart';
import 'route_value.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();

final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildGoRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteValue.home.path,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) {
        return NoTransitionPage(
          child: RootNavigationScreen(
            navigationShell: navigationShell,
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
                path: RouteValue.home.path,
                builder: (BuildContext context, GoRouterState state) {
                  return HomeScreen();
                },
                routes: [
                  GoRoute(
                    path: RouteValue.achievement.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return AchievementScreen();
                    },
                  ),
                  GoRoute(
                      path: RouteValue.select.path,
                      builder: (BuildContext context, GoRouterState state) {
                        return SelectionScreen();
                      },
                      routes: [
                        GoRoute(
                          path: RouteValue.game.path,
                          builder: (BuildContext context, GoRouterState state) {
                            return GameScreen(size: 5 + (state.extra as int));
                          },
                        ),
                      ]),
                ]),
          ],
        ),
      ],
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.black,
            child: child,
          ),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouteValue.splash.path,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          },
        ),
      ],
    ),
  ],
);
