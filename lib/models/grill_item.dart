import 'package:uuid/uuid.dart';
import 'package:ultimate_grill_timer/models/grill_timer.dart';

class GrillItem {
  final String id;
  final GrillTimer timer;
  final GrillTimer? flipTimer;
  final String image;
  final int flips;
  bool isPaused;

  GrillItem({
    String? id,
    required this.timer,
    required this.image,
    this.flips = 0,
    this.flipTimer,
    this.isPaused = false,
  }) : id = id ?? const Uuid().v4();

  GrillItem flip() {
    return copyWith(flips: flips + 1, flipTimer: GrillTimer(startTime: DateTime.now()));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timer': timer.toMap(),
      'flipTimer': flipTimer?.toMap(),
      'image': image,
      'flips': flips,
      'isPaused': isPaused,
    };
  }

  static GrillItem fromMap(Map<String, dynamic> map) {
    return GrillItem(
      id: map['id'],
      timer: GrillTimer.fromMap(map['timer'])!,
      flipTimer: GrillTimer.fromMap(map['flipTimer']),
      image: map['image'] ?? '',
      flips: map['flips'] ?? 0,
      isPaused: map['isPaused'] ?? false,
    );
  }

  GrillItem copyWith({
    String? id,
    GrillTimer? timer,
    GrillTimer? flipTimer,
    String? image,
    int? flips,
    bool? isPaused,
  }) {
    return GrillItem(
      id: id ?? this.id,
      timer: timer ?? this.timer,
      flipTimer: flipTimer ?? this.flipTimer,
      image: image ?? this.image,
      flips: flips ?? this.flips,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  void resume() {
    isPaused = false;
    if (flipTimer != null) {
      flipTimer!.resume();
    }
    timer.resume();
  }

  void pause() {
    isPaused = true;
    timer.pause();
    if (flipTimer != null) {
      flipTimer!.pause();
    }
  }
}
