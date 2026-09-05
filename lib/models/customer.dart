class Customer {
  final int? id;
  final String aadharNumber;
  final String name;
  final int age;
  final String contactNumber;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.aadharNumber,
    required this.name,
    required this.age,
    required this.contactNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aadharNumber': aadharNumber,
      'name': name,
      'age': age,
      'contactNumber': contactNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      aadharNumber: map['aadharNumber'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      contactNumber: map['contactNumber'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
