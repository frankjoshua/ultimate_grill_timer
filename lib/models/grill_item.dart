import 'package:ultimate_grill_timer/models/grill_timer.dart';

class GrillItem {
  final GrillTimer timer;
  final String image;

  GrillItem({required this.timer, required this.image});

  toMap() {
    return {
      'timer': timer.toMap(),
      'image': image,
    };
  }

  static fromMap(Map<String, dynamic> map) {
    return GrillItem(
      timer: GrillTimer.fromMap(map['timer']),
      image: map['image'],
    );
  }

  GrillItem copyWith({GrillTimer? timer, String? image}) {
    return GrillItem(
      timer: timer ?? this.timer,
      image: image ?? this.image,
    );
  }
}