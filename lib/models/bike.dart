class Bike {
  final int? id;
  final String model;
  final String number;
  final String colour;
  final String status; // 'available' or 'rented'
  final DateTime createdAt;

  Bike({
    this.id,
    required this.model,
    required this.number,
    required this.colour,
    this.status = 'available',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Bike copyWith({
    int? id,
    String? model,
    String? number,
    String? colour,
    String? status,
    DateTime? createdAt,
  }) {
    return Bike(
      id: id ?? this.id,
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
      'model': model,
      'number': number,
      'colour': colour,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'] as int?,
      model: map['model'] as String,
      number: map['number'] as String,
      colour: map['colour'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
