import 'vehicle_type.dart';

class Vehicle {
  final int? id;
  final VehicleType type;
  final String model;
  final String number;
  final String colour;
  final String status; // 'available' or 'rented'
  final DateTime createdAt;

  Vehicle({
    this.id,
    required this.type,
    required this.model,
    required this.number,
    required this.colour,
    this.status = 'available',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Vehicle copyWith({
    int? id,
    VehicleType? type,
    String? model,
    String? number,
    String? colour,
    String? status,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      type: type ?? this.type,
      model: model ?? this.model,
      number: number ?? this.number,
      colour: colour ?? this.colour,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'model': model,
      'number': number,
      'colour': colour,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      type: VehicleTypeX.fromKey(map['type'] as String),
      model: map['model'] as String,
      number: map['number'] as String,
      colour: map['colour'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
