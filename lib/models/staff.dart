class Staff {
  final int? id;
  final String name;
  final String phone;
  final String role;
  final DateTime joiningDate;
  final double salary;
  final DateTime createdAt;

  Staff({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.joiningDate,
    required this.salary,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'joiningDate': joiningDate.toIso8601String(),
      'salary': salary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
      joiningDate: DateTime.parse(map['joiningDate'] as String),
      salary: (map['salary'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
