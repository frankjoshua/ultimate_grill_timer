import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';
import '../providers/grill_assets_provider.dart';
import '../providers/grill_items_provider.dart';

/// Picker-only screen the watch tile's Add button opens: just the food icons.
/// Tap one -> timer starts -> back to the tile.
class AddFoodScreen extends ConsumerWidget {
  const AddFoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(grillAssetsProvider);
    // Edge rows may clip on the round screen — normal on watches. The vertical
    // padding is overscroll room so every row can reach the fully-visible center.
    final overscroll = MediaQuery.of(context).size.height * 0.38;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: overscroll),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final asset in assets)
            InkWell(
              onTap: () async {
                ref.read(grillItemsProvider.notifier).addGrillItem(
                      GrillItem(
                        timer: GrillTimer(startTime: DateTime.now()),
                        image: asset.image,
                      ),
                    );
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  // Launched straight from the tile: this screen is the whole
                  // app, so close back to the tile.
                  // ponytail: let SaveStateWidget's async save land before the
                  // activity finishes; an explicit awaited save if this ever races
                  await Future.delayed(const Duration(milliseconds: 400));
                  SystemNavigator.pop();
                }
              },
              // cacheWidth: decode the 512px asset small; full-size decodes jank the scroll
              child: Image.asset(asset.image, cacheWidth: 176),
            ),
        ],
      ),
    );
  }
}
