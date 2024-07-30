import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grill_timer.dart';
import '../providers/timers_provider.dart';

class TimerList extends ConsumerWidget {
  const TimerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(timersProvider);
    return ListView.builder(
      itemCount: timers.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextTimer(timer: timers[index]),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
                if (!timers[index].isPaused)
                  IconButton(
                    onPressed: () {
                      timers[index].pause();
                    },
                    icon: const Icon(Icons.pause),
                  )
                else
                  IconButton(
                    onPressed: () {
                      timers[index].resume();
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
                IconButton(
                  onPressed: () {
                    ref.read(timersProvider.notifier).removeTimer(timers[index]);
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
  const TextTimer({super.key, required this.timer});

  final GrillTimer timer;

  @override
  Widget build(BuildContext context) {
    return Text(timer.getFormattedElapsedTime(), style: Theme.of(context).textTheme.displayLarge);
  }
}