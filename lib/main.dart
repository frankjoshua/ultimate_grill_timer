import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultimate_grill_timer/views/add_grill_item_button_row.dart';
import 'package:ultimate_grill_timer/views/timer_list.dart';

import 'managers/timer_manager.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TimerManager(
      child: MaterialApp(
        title: 'Ultimate Grill Timer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Ultimate Grill Timer'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: TimerList()),
          ],
        ),
      ),
      floatingActionButton: AddGrillItemButtonRow(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

