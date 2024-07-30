import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';

final grillItemsProvider = StateNotifierProvider<GrillItemsProvider, List<GrillItem>>((ref) {
  return GrillItemsProvider();
});


class GrillItemsProvider extends StateNotifier<List<GrillItem>> {
  GrillItemsProvider() : super([]);

  void addGrillItem(GrillItem grillItem) {
    state = [...state, grillItem];
  }

  void removeGrillItem(GrillItem grillItem) {
    state = [...state]..remove(grillItem);
  }

  void refresh() {
    state = List.from(state);
  }
}