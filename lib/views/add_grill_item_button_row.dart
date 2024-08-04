import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';
import '../providers/grill_assets_provider.dart';
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
    final grillItem =
        GrillItem(timer: GrillTimer(startTime: DateTime.now()), image: image);
    ref.read(grillItemsProvider.notifier).addGrillItem(grillItem);
  }

  @override
  Widget build(BuildContext context) {
    final grillAssets = ref.watch(grillAssetsProvider);
    final grillItems = ref.watch(grillItemsProvider);
    double height;
    if(grillItems.length > 3) {
      height = 50.0;
    } else {
      height = 100.0;
    };
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: height, // Adjust the height to fit the desired number of rows
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 75.0, // Maximum width for each item
            mainAxisSpacing: 8.0, // Spacing between items horizontally
            crossAxisSpacing: 8.0, // Spacing between items vertically
            childAspectRatio: 1.0, // Aspect ratio of the items
          ),
          itemCount: grillAssets.length,
          itemBuilder: (context, index) {
            final asset = grillAssets[index];
            return FloatingActionButton(
              onPressed: () { _addTimer(asset.image); },
              tooltip: 'Add Timer',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(asset.image),
              ),
            );
          },
        ),
      ),
    );
  }
}
