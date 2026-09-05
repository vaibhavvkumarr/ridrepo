import 'vehicle_type.dart';

class Vehicle {
  final int? id;
  final VehicleType type;
  final String model;
  final String number;
  final String colour;
  final String status; // 'available' or 'rented'
  final DateTime createdAt;
  final DateTime? insuranceExpiry;
  final DateTime? pollutionExpiry;

  Vehicle({
    this.id,
    required this.type,
    required this.model,
    required this.number,
    required this.colour,
    this.status = 'available',
    DateTime? createdAt,
    this.insuranceExpiry,
    this.pollutionExpiry,
  }) : createdAt = createdAt ?? DateTime.now();

  Vehicle copyWith({
    int? id,
    VehicleType? type,
    String? model,
    String? number,
    String? colour,
    String? status,
    DateTime? createdAt,
    DateTime? insuranceExpiry,
    DateTime? pollutionExpiry,
  }) {
    return Vehicle(
      id: id ?? this.id,
      type: type ?? this.type,
      model: model ?? this.model,
      number: number ?? this.number,
      colour: colour ?? this.colour,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      pollutionExpiry: pollutionExpiry ?? this.pollutionExpiry,
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
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'pollutionExpiry': pollutionExpiry?.toIso8601String(),
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
      insuranceExpiry: map['insuranceExpiry'] != null
          ? DateTime.parse(map['insuranceExpiry'] as String)
          : null,
      pollutionExpiry: map['pollutionExpiry'] != null
          ? DateTime.parse(map['pollutionExpiry'] as String)
          : null,
    );
  }
}
