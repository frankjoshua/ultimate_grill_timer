import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grill_item.dart';
import '../providers/grill_items_provider.dart';

/// Watch main screen: one scrollable list — timer rows, then the Add row,
/// which scrolls with (and off) the list like any other row. Overscroll
/// padding lets any row reach the fully-visible center of the round screen;
/// edge rows clip, which is normal on watches.
class WatchHomeScreen extends ConsumerStatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  ConsumerState<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends ConsumerState<WatchHomeScreen> {
  // Wear OS kills the process on every exit, so the offset is persisted;
  // the static covers rebuilds within one process life.
  static const _scrollPrefKey = 'watchScrollOffset';
  static double _lastOffset = 0;
  late final ScrollController _controller =
      ScrollController(initialScrollOffset: _lastOffset)
        ..addListener(() => _lastOffset = _controller.offset);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getDouble(_scrollPrefKey);
      if (saved != null && mounted && _lastOffset == 0 && _controller.hasClients) {
        _controller.jumpTo(saved);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(grillItemsProvider);
    final overscroll = MediaQuery.of(context).size.height * 0.38;
    return Scaffold(
      backgroundColor: Colors.black,
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          SharedPreferences.getInstance()
              .then((prefs) => prefs.setDouble(_scrollPrefKey, _controller.offset));
          return false;
        },
        child: ListView(
        controller: _controller,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: overscroll),
        children: [
          for (final item in items) WatchTimerRow(item: item),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('/add'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C3C3C),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('+',
                            style: TextStyle(fontSize: 22, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Add',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class WatchTimerRow extends ConsumerWidget {
  const WatchTimerRow({super.key, required this.item});

  final GrillItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same gestures as the phone list: icon = flip, time = pause/resume,
    // swipe = delete.
    // Right-to-left only: left-to-right is the Wear OS back gesture.
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.withValues(alpha: 0.35),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(grillItemsProvider.notifier).removeGrillItem(item),
      child: Opacity(
        opacity: item.isPaused ? 0.4 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  final flipped = item.flip();
                  ref.read(grillItemsProvider.notifier).removeGrillItem(item);
                  ref.read(grillItemsProvider.notifier).addGrillItem(flipped);
                },
                // cacheWidth: decode the 512px asset small; full-size decodes jank the scroll
                child: Image.asset(item.image, width: 35, height: 35, cacheWidth: 105),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => item.isPaused ? item.resume() : item.pause(),
                child: Text(
                  item.timer.getFormattedElapsedTime(),
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
