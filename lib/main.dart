import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultimate_grill_timer/views/add_food_screen.dart';
import 'package:ultimate_grill_timer/views/add_grill_item_button_row.dart';
import 'package:ultimate_grill_timer/views/instructions_view.dart';
import 'package:ultimate_grill_timer/views/timer_list.dart';
import 'package:ultimate_grill_timer/views/watch_home_screen.dart';

import 'managers/save_state_widget.dart';
import 'managers/timer_manager.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // MainActivity.getInitialRoute sets "/watch" on watch hardware and "/add"
    // when the tile's Add button launched the app.
    final initialRoute = PlatformDispatcher.instance.defaultRouteName;
    return TimerManager(
      child: SaveStateWidget(
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Ultimate Grill Timer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: switch (initialRoute) {
            '/add' => const AddFoodScreen(),
            '/watch' => const WatchHomeScreen(),
            _ => const MyHomePage(title: 'Ultimate Grill Timer'),
          },
          routes: {
            '/add': (_) => const AddFoodScreen(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: TimerList()),
              Instructions(),
              SizedBox(height: 16),
              AddGrillItemButtonRow(),
            ],
          ),
        ),
      ),
    );
  }
}
