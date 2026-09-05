import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle_type.dart';

/// Which vehicle types the manager wants listed as tiles on the home
/// dashboard. Persisted as the set of *hidden* types (rather than the
/// visible ones) so that a vehicle type added in a future app update shows
/// up by default even for managers who already customised this — it was
/// never explicitly hidden by them.
class VehicleVisibilityController {
  VehicleVisibilityController._();
  static final VehicleVisibilityController instance =
      VehicleVisibilityController._();

  static const _prefsKey = 'hidden_vehicle_types';

  final ValueNotifier<Set<VehicleType>> visibleTypes =
      ValueNotifier(VehicleType.values.toSet());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hidden =
        (prefs.getStringList(_prefsKey) ?? []).map(VehicleTypeX.fromKey);
    final visible = VehicleType.values.toSet()..removeAll(hidden);
    visibleTypes.value = visible.isEmpty ? VehicleType.values.toSet() : visible;
  }

  /// Shows or hides [type] on the home dashboard. Returns false (and makes
  /// no change) if this would hide every vehicle type — at least one must
  /// always stay visible.
  Future<bool> setVisible(VehicleType type, bool visible) async {
    final updated = Set<VehicleType>.from(visibleTypes.value);
    if (visible) {
      updated.add(type);
    } else {
      updated.remove(type);
      if (updated.isEmpty) return false;
    }
    visibleTypes.value = updated;
    final hidden = VehicleType.values.toSet()..removeAll(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      hidden.map((t) => t.name).toList(),
    );
    return true;
  }
}
