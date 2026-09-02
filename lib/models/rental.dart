class Rental {
  final int? id;
  final int bikeId;

  // Customer details
  final String customerName;
  final int age;
  final String contactNumber;
  final String aadharNumber;
  final String personWithBikePhotoPath;
  final String licensePhotoPath;

  // Trip window
  final DateTime startDateTime;
  final DateTime endDateTime;

  // Money
  final double rentCharge;
  final double deposit;

  // Lifecycle
  final String status; // 'active' or 'completed'
  final DateTime? actualReturnDateTime;

  Rental({
    this.id,
    required this.bikeId,
    required this.customerName,
    required this.age,
    required this.contactNumber,
    required this.aadharNumber,
    required this.personWithBikePhotoPath,
    required this.licensePhotoPath,
    required this.startDateTime,
    required this.endDateTime,
    required this.rentCharge,
    required this.deposit,
    this.status = 'active',
    this.actualReturnDateTime,
  });

  bool get isOverdue =>
      status == 'active' && DateTime.now().isAfter(endDateTime);

  Rental copyWith({
    String? status,
    DateTime? actualReturnDateTime,
  }) {
    return Rental(
      id: id,
      bikeId: bikeId,
      customerName: customerName,
      age: age,
      contactNumber: contactNumber,
      aadharNumber: aadharNumber,
      personWithBikePhotoPath: personWithBikePhotoPath,
      licensePhotoPath: licensePhotoPath,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      rentCharge: rentCharge,
      deposit: deposit,
      status: status ?? this.status,
      actualReturnDateTime: actualReturnDateTime ?? this.actualReturnDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bikeId': bikeId,
      'customerName': customerName,
      'age': age,
      'contactNumber': contactNumber,
      'aadharNumber': aadharNumber,
      'personWithBikePhotoPath': personWithBikePhotoPath,
      'licensePhotoPath': licensePhotoPath,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'rentCharge': rentCharge,
      'deposit': deposit,
      'status': status,
      'actualReturnDateTime': actualReturnDateTime?.toIso8601String(),
    };
  }

  factory Rental.fromMap(Map<String, dynamic> map) {
    return Rental(
      id: map['id'] as int?,
      bikeId: map['bikeId'] as int,
      customerName: map['customerName'] as String,
      age: map['age'] as int,
      contactNumber: map['contactNumber'] as String,
      aadharNumber: map['aadharNumber'] as String,
      personWithBikePhotoPath: map['personWithBikePhotoPath'] as String,
      licensePhotoPath: map['licensePhotoPath'] as String,
      startDateTime: DateTime.parse(map['startDateTime'] as String),
      endDateTime: DateTime.parse(map['endDateTime'] as String),
      rentCharge: (map['rentCharge'] as num).toDouble(),
      deposit: (map['deposit'] as num).toDouble(),
      status: map['status'] as String,
      actualReturnDateTime: map['actualReturnDateTime'] != null
          ? DateTime.parse(map['actualReturnDateTime'] as String)
          : null,
    );
  }
}
