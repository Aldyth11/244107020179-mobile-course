import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:week_3_navigation_state_management/Praktikum2/pages/todo_page.dart';
import 'package:week_3_navigation_state_management/Challenge/stats_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.matchedLocation == '/stats' ? 1 : 0,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/');
              } else {
                context.go('/stats');
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.list_alt),
                label: 'ToDo',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
  ],
);