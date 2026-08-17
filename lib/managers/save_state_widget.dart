import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_grill_timer/models/grill_item.dart';
import 'package:ultimate_grill_timer/providers/grill_items_provider.dart';

import '../use_case/restore_grill_items_use_case.dart';
import '../use_case/save_grill_items_use_case.dart';

/// SaveStateWidget sits above MaterialApp, so navigation goes through this key.
final appNavigatorKey = GlobalKey<NavigatorState>();

class SaveStateWidget extends ConsumerStatefulWidget{
  final Widget child;

  SaveStateWidget({super.key, required this.child});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SaveStateWidgetState();
  }
}

class SaveStateWidgetState extends ConsumerState<SaveStateWidget>{
  static const _syncChannel = MethodChannel('grill_sync');
  bool _reloading = false;

  @override
  initState(){
    super.initState();
    RestoreGrillItemsUseCase().execute(ref);
    ref.listenManual(grillItemsProvider, (previous, next){
      if(previous != null && !_reloading && shouldSave(next, previous)){
        SaveGrillItemsUseCase().execute(ref, next);
      }
    });
    // Native side calls this when newer state arrives from the other device,
    // or when the tile's Add button relaunches an already-running app.
    _syncChannel.setMethodCallHandler((call) async {
      if (call.method == 'showAdd') {
        appNavigatorKey.currentState?.pushNamed('/add');
      }
      if (call.method == 'reload') {
        _reloading = true;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          await RestoreGrillItemsUseCase().execute(ref);
        } finally {
          _reloading = false;
        }
      }
    });
  }

  bool shouldSave(List<GrillItem> next, List<GrillItem> previous) {
    if(next.length != previous.length){
      return true;
    }
    for(int i = 0; i < next.length; i++){
      if(next[i].flips != previous[i].flips){
        return true;
      }
    }
    return false;
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}



