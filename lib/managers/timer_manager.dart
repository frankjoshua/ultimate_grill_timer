import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers/timers_provider.dart';

class TimerManager extends ConsumerStatefulWidget {
  const TimerManager({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return TimerManagerState();
  }
}

class TimerManagerState extends ConsumerState<TimerManager> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      _updateTimers();
    });
  }

  void _updateTimers() {
    ref.read(timersProvider.notifier).refresh();
    // Read the timers from the provider
    // List<GrillTimer> timers = ref.read(timersProvider);
    //
    // // Update each timer
    // for (var timer in timers) {
    //   // timer.updateTime();
    // }

    // Notify the provider about the update
    // ref.read(timersProvider.notifier).update(timers);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
