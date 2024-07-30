import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';
import '../providers/grill_items_provider.dart';

class AddGrillItemButtonRow extends ConsumerStatefulWidget {
  const AddGrillItemButtonRow({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddGrillItemButtonRowState();
  }
}

class _AddGrillItemButtonRowState extends ConsumerState<AddGrillItemButtonRow> {

  void _addTimer(String image) {
    final grillItem = GrillItem(
        timer: GrillTimer(startTime: DateTime.now()),
        image: image
    );
    ref.read(grillItemsProvider.notifier).addGrillItem(grillItem);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        FloatingActionButton(
          onPressed: () { _addTimer('assets/images/meat.png'); },
          tooltip: 'Add Timer',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/meat.png'),
          ),
        ),
        FloatingActionButton(
          onPressed: () { _addTimer('assets/images/corn.png'); },
          tooltip: 'Add Timer',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/corn.png'),
          ),
        ),
        FloatingActionButton(
          onPressed: () { _addTimer('assets/images/burger.png'); },
          tooltip: 'Add Timer',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/burger.png'),
          ),
        ),
        FloatingActionButton(
          onPressed: () { _addTimer('assets/images/potato.png'); },
          tooltip: 'Add Timer',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/potato.png'),
          ),
        ),
      ],
    );
  }
}