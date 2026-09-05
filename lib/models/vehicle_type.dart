import 'package:flutter/material.dart';

/// Every kind of vehicle the fleet can contain. Stored in the database as
/// [name] (e.g. 'bike', 'car'), so don't reorder/rename existing values.
enum VehicleType { bike, car, auto, bus, truck, others }

extension VehicleTypeX on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.car:
        return 'Car';
      case VehicleType.auto:
        return 'Auto';
      case VehicleType.bus:
        return 'Bus';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.others:
        return 'Other';
    }
  }

  String get pluralLabel {
    switch (this) {
      case VehicleType.bike:
        return 'Bikes';
      case VehicleType.car:
        return 'Cars';
      case VehicleType.auto:
        return 'Autos';
      case VehicleType.bus:
        return 'Buses';
      case VehicleType.truck:
        return 'Trucks';
      case VehicleType.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.bike:
        return Icons.two_wheeler_rounded;
      case VehicleType.car:
        return Icons.directions_car_rounded;
      case VehicleType.auto:
        return Icons.electric_rickshaw_rounded;
      case VehicleType.bus:
        return Icons.directions_bus_rounded;
      case VehicleType.truck:
        return Icons.local_shipping_rounded;
      case VehicleType.others:
        return Icons.construction_rounded;
    }
  }

  String get modelHint {
    switch (this) {
      case VehicleType.bike:
        return 'e.g. Honda Activa 6G';
      case VehicleType.car:
        return 'e.g. Maruti Swift';
      case VehicleType.auto:
        return 'e.g. Bajaj RE Auto';
      case VehicleType.bus:
        return 'e.g. Tata Starbus';
      case VehicleType.truck:
        return 'e.g. Tata 407';
      case VehicleType.others:
        return 'e.g. JCB, Crane, Bulldozer, Tractor';
    }
  }

  static VehicleType fromKey(String key) {
    return VehicleType.values.firstWhere(
      (t) => t.name == key,
      orElse: () => VehicleType.bike,
    );
  }
}
