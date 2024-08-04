import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultimate_grill_timer/providers/grill_items_provider.dart';

class Instructions extends ConsumerWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grillItems = ref.watch(grillItemsProvider);
    final messages = <Widget>[];

    if (grillItems.isEmpty) {
      messages.add(const Text("Tap a food to start a timer"));
    }
    if (grillItems.isNotEmpty && grillItems.length < 2) {
      messages.addAll([
        const InstructionRow(text: "Swipe timers to delete"),
        const InstructionRow(text: "Tap a food to start the flip timer"),
        const InstructionRow(text: "Tap the time to pause/resume"),
      ]);
    }

    return Column(
      children: messages,
    );
  }
}

class InstructionRow extends StatelessWidget {
  final String text;

  const InstructionRow({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(text),
      ],
    );
  }
}
