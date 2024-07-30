class GrillTimer {
  final DateTime startTime;
  bool isPaused;
  Duration pauseDuration;
  DateTime? pauseStartTime;

  GrillTimer({
    required this.startTime,
    this.isPaused = false,
    this.pauseDuration = Duration.zero,
    this.pauseStartTime,
  });

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



  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'isPaused': isPaused,
      'pauseDuration': pauseDuration.inSeconds,
      'pauseStartTime': pauseStartTime?.toIso8601String(),
    };
  }

  static GrillTimer? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return GrillTimer(
      startTime: DateTime.parse(map['startTime']),
      isPaused: map['isPaused'],
      pauseDuration: Duration(seconds: map['pauseDuration']),
      pauseStartTime: map['pauseStartTime'] != null ? DateTime.parse(map['pauseStartTime']) : null,
    );
  }

  GrillTimer copyWith({
    DateTime? startTime,
    bool? isPaused,
    Duration? pauseDuration,
    DateTime? pauseStartTime,
    int? flips,
    DateTime? lastFlipTime,
  }) {
    return GrillTimer(
      startTime: startTime ?? this.startTime,
      isPaused: isPaused ?? this.isPaused,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      pauseStartTime: pauseStartTime ?? this.pauseStartTime,
    );
  }
}
