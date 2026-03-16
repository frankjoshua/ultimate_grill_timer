import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_asset.dart';

final grillAssetsProvider = StateNotifierProvider<GrillAssetsStateNotifier, List<GrillAsset>>((ref) {
  return GrillAssetsStateNotifier();
});



class GrillAssetsStateNotifier extends StateNotifier<List<GrillAsset>> {
  GrillAssetsStateNotifier() : super(defaultAssets);

  static final defaultAssets = [
    GrillAsset(image: 'assets/images/potato.png'),
    GrillAsset(image: 'assets/images/corn.png'),
    GrillAsset(image: 'assets/images/asparagus.png'),
    GrillAsset(image: 'assets/images/burger.png'),
    GrillAsset(image: 'assets/images/meat.png'),
    GrillAsset(image: 'assets/images/chicken-leg.png'),
    GrillAsset(image: 'assets/images/chop.png'),
    GrillAsset(image: 'assets/images/fish.png'),
    GrillAsset(image: 'assets/images/hot-dog.png'),
    GrillAsset(image: 'assets/images/pineapple.png'),
    GrillAsset(image: 'assets/images/ribs.png'),
    GrillAsset(image: 'assets/images/sausages.png'),
    GrillAsset(image: 'assets/images/shrimp.png'),
    GrillAsset(image: 'assets/images/skewer.png'),
    GrillAsset(image: 'assets/images/carrot.png'),
    GrillAsset(image: 'assets/images/bell-pepper.png'),
    GrillAsset(image: 'assets/images/mushroom.png'),
    GrillAsset(image: 'assets/images/onion.png'),
    GrillAsset(image: 'assets/images/zucchini.png'),
    GrillAsset(image: 'assets/images/bacon.png'),
    GrillAsset(image: 'assets/images/lobster.png'),
    GrillAsset(image: 'assets/images/jalapeno.png'),
    GrillAsset(image: 'assets/images/tomato.png'),
    GrillAsset(image: 'assets/images/bread.png'),
  ];

  void addAsset(GrillAsset asset) {
    state = [...state, asset];
  }

  void removeAsset(GrillAsset asset) {
    state = [...state]..remove(asset);
  }

  void restoreAssets(List<GrillAsset> assets) {
    state = List.from(assets);
  }

  void refresh() {
    state = List.from(state);
  }
}