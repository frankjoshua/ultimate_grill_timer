import 'dart:convert';

import 'grill_item.dart';

class GrillItemsSaveState {
  final List<GrillItem> grillItems;
  final int saveTime;

  GrillItemsSaveState({required this.grillItems, required this.saveTime});

  String toJson() {
    return jsonEncode(toMap());
  }

  toMap() {
    return {
      'grillItems': grillItems.map((e) => e.toMap()).toList(),
      'saveTime': saveTime,
    };
  }

  static GrillItemsSaveState fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return fromMap(map);
  }

  static GrillItemsSaveState fromMap(Map<String, dynamic> map) {
    return GrillItemsSaveState(
      grillItems: List<GrillItem>.from(map['grillItems'].map((e) => GrillItem.fromMap(e))),
      saveTime: map['saveTime'],
    );
  }
}