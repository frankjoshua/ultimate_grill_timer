import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_grill_timer/models/grill_timer.dart';

void main() {
  test('elapsed time formats without zero-padded minutes', () {
    final underHour = GrillTimer(
      startTime: DateTime.now().subtract(const Duration(minutes: 5, seconds: 7)),
    );
    expect(underHour.getFormattedElapsedTime(), '5:07');

    final overHour = GrillTimer(
      startTime: DateTime.now()
          .subtract(const Duration(hours: 2, minutes: 3, seconds: 9)),
    );
    expect(overHour.getFormattedElapsedTime(), '2:03:09');
  });

  test('paused timer freezes elapsed time', () {
    final timer = GrillTimer(
      startTime: DateTime.now().subtract(const Duration(minutes: 10)),
    );
    timer.pause();
    final frozen = timer.getFormattedElapsedTime();
    expect(timer.getFormattedElapsedTime(), frozen);
  });
}
