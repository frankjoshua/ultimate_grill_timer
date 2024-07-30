
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grill_item.dart';
import '../models/grill_items_save_state.dart';

class SaveGrillItemsUseCase {
  Future<void> execute(WidgetRef ref, List<GrillItem> grillItems) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final GrillItemsSaveState grillItemsSaveState = GrillItemsSaveState(
        grillItems: grillItems,
        saveTime: DateTime.now().millisecondsSinceEpoch);
    final String json = grillItemsSaveState.toJson();
    await prefs.setString('grillItems', json);
    print('Save grill items');
    print(json);
  }
}
