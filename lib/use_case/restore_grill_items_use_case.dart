import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grill_items_save_state.dart';
import '../providers/grill_items_provider.dart';

class RestoreGrillItemsUseCase {
  Future<void> execute(WidgetRef ref) async {
    print('Restore grill items');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = await prefs.getString('grillItems');
    if (json != null) {
      print(json);
      final GrillItemsSaveState grillItemsSaveState =
          GrillItemsSaveState.fromJson(json);
      ref.read(grillItemsProvider.notifier).restoreGrillItems(grillItemsSaveState.grillItems);
    }
  }
}