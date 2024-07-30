import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_timer.dart';

final timersProvider = StateNotifierProvider<TimersProvider, List<GrillTimer>>((ref) {
  return TimersProvider();
});


class TimersProvider extends StateNotifier<List<GrillTimer>> {
  TimersProvider() : super([]);

  void addTimer(GrillTimer timer) {
    state = [...state, timer];
  }

  void removeTimer(GrillTimer timer) {
    state = [...state]..remove(timer);
  }

  void refresh() {
    state = List.from(state);
  }
}