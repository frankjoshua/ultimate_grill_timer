import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../providers/grill_items_provider.dart';

class TimerList extends ConsumerWidget {
  const TimerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(grillItemsProvider);
    return ListView.builder(
      itemCount: timers.length,
      itemBuilder: (context, index) {
        var grillItem = timers[index];
        var timer = grillItem.timer;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(grillItem.image, width: 50, height: 50),
                const SizedBox(width: 10),
                TextTimer(grillItem: grillItem),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
                if (!timer.isPaused)
                  IconButton(
                    onPressed: () {
                      timer.pause();
                    },
                    icon: const Icon(Icons.pause),
                  )
                else
                  IconButton(
                    onPressed: () {
                      timer.resume();
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
                IconButton(
                  onPressed: () {
                    ref.read(grillItemsProvider.notifier).removeGrillItem(grillItem);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}

class TextTimer extends StatelessWidget {
  const TextTimer({super.key, required this.grillItem});

  final GrillItem grillItem;

  @override
  Widget build(BuildContext context) {
    return Text(grillItem.timer.getFormattedElapsedTime(), style: Theme.of(context).textTheme.displayLarge);
  }
}