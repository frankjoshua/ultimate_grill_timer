class GrillTimer {
  final DateTime startTime;
  bool isPaused;
  Duration pauseDuration;
  DateTime? pauseStartTime;

  GrillTimer({required this.startTime})
      : isPaused = false,
        pauseDuration = Duration.zero,
        pauseStartTime = null;

  Duration get elapsedTime {
    final currentTime = DateTime.now();
    if (isPaused) {
      return pauseStartTime!.difference(startTime) - pauseDuration;
    } else {
      return currentTime.difference(startTime) - pauseDuration;
    }
  }

  void pause() {
    if (!isPaused) {
      isPaused = true;
      pauseStartTime = DateTime.now();
    }
  }

  void resume() {
    if (isPaused) {
      isPaused = false;
      pauseDuration += DateTime.now().difference(pauseStartTime!);
      pauseStartTime = null;
    }
  }

  String getFormattedElapsedTime() {
    final elapsed = elapsedTime;
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
