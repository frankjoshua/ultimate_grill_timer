import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultimate_grill_timer/models/grill_item.dart';
import 'package:ultimate_grill_timer/providers/grill_items_provider.dart';

import '../use_case/restore_grill_items_use_case.dart';
import '../use_case/save_grill_items_use_case.dart';

class SaveStateWidget extends ConsumerStatefulWidget{
  final Widget child;

  SaveStateWidget({super.key, required this.child});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SaveStateWidgetState();
  }
}

class SaveStateWidgetState extends ConsumerState<SaveStateWidget>{
  
  @override
  initState(){
    super.initState();
    RestoreGrillItemsUseCase().execute(ref);
    ref.listenManual(grillItemsProvider, (previous, next){
      if(previous != null && shouldSave(next, previous)){
        SaveGrillItemsUseCase().execute(ref, next);
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



