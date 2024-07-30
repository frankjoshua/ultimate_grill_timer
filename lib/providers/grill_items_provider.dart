import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';

final grillItemsProvider = StateNotifierProvider<GrillItemsProvider, List<GrillItem>>((ref) {
  return GrillItemsProvider();
});


class GrillItemsProvider extends StateNotifier<List<GrillItem>> {
  GrillItemsProvider() : super([]);

  void addGrillItem(GrillItem grillItem) {
    state = _syncGrillItems([...state, grillItem]);
  }

  void removeGrillItem(GrillItem grillItem) {
    state = _syncGrillItems([...state]..remove(grillItem));
  }

  List<GrillItem> _syncGrillItems(List<GrillItem> grillItems) {
    if (grillItems.isEmpty) return grillItems;

    // Get the current time with millisecond precision
    final syncTime = grillItems.first.timer.startTime;

    // Update each GrillTimer to have the same millisecond precision
    final syncedGrillItems = grillItems.map((item) {
      final updatedTimer = item.timer.copyWith(
          startTime: item.timer.startTime.copyWith(millisecond: syncTime.millisecond),
      );

      return item.copyWith(timer: updatedTimer);
    }).toList();

    return syncedGrillItems;
  }

  void restoreGrillItems(List<GrillItem> grillItems) {
    state = List.from(grillItems);
  }

  void refresh() {
    state = List.from(state);
  }
}