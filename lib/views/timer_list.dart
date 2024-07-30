import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_item.dart';
import '../models/grill_timer.dart';
import '../providers/grill_items_provider.dart';

class TimerList extends ConsumerWidget {
  const TimerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(grillItemsProvider);
    return Center(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: timers.length,
        itemBuilder: (context, index) {
          var grillItem = timers[index];
          var timer = grillItem.timer;
          return Column(
            children: [
              if (index == 0) const Divider(),
              Dismissible(
                key: Key(grillItem.id),
                background: Container(
                  color: Colors.red.withOpacity(0.5),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (direction) {
                  ref
                      .read(grillItemsProvider.notifier)
                      .removeGrillItem(grillItem);
                },
                child: Opacity(
                  opacity: timer.isPaused ? 0.5 : 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        onTap: () {
                          final flippedItem = grillItem.flip();
                          ref.read(grillItemsProvider.notifier).removeGrillItem(grillItem);
                          ref.read(grillItemsProvider.notifier).addGrillItem(flippedItem);
                        },
                        child: GrillItemIcon(grillItem: grillItem),
                      ),
                      InkWell(
                          onTap: () {
                            if (grillItem.isPaused) {
                              grillItem.resume();
                            } else {
                              grillItem.pause();
                            }
                          },
                          child: TextTimer(grillItem: grillItem)),
                      if (grillItem.isPaused)
                        IconButton(
                          onPressed: () {
                            grillItem.resume();
                          },
                          icon: const Icon(Icons.pause),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}

class GrillItemIcon extends StatelessWidget {
  const GrillItemIcon({
    super.key,
    required this.grillItem,
  });

  final GrillItem grillItem;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(grillItem.flips.isOdd ? 3.14159 : 0), // Rotate by 180 degrees if flips is odd
            child: Image.asset(
              grillItem.image,
              width: 60,
              height: 60,
            ),
          ),
          if (grillItem.flips > 0 && grillItem.flipTimer != null)
            FlipCounter(timer: grillItem.flipTimer!, flips: grillItem.flips),
        ]);
  }
}

class FlipCounter extends StatelessWidget {
  const FlipCounter({
    super.key,
    required this.timer,
    required this.flips,
  });

  final GrillTimer timer;
  final int flips;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Text(flips.toString(),
                style: Theme
                    .of(context)
                    .textTheme
                    .labelSmall),
            const SizedBox(width: 5),
            Text(timer.getFormattedElapsedTime(),
                style: Theme
                    .of(context)
                    .textTheme
                    .labelSmall),
          ],
        ),
      ),
    );
  }
}

class TextTimer extends StatelessWidget {
  const TextTimer({super.key, required this.grillItem});

  final GrillItem grillItem;

  @override
  Widget build(BuildContext context) {
    return Text(grillItem.timer.getFormattedElapsedTime(),
        style: Theme.of(context).textTheme.displayLarge);
  }
}
