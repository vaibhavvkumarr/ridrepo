import 'vehicle_type.dart';

class Rental {
  final int? id;
  final int vehicleId;
  final VehicleType vehicleType;
  final int? customerId;

  // Customer details
  final String customerName;
  final int age;
  final String contactNumber;
  final String aadharNumber;
  final String personWithVehiclePhotoPath;
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
  final int? rating; // 1-5, given by the manager when the trip ends

  Rental({
    this.id,
    required this.vehicleId,
    required this.vehicleType,
    this.customerId,
    required this.customerName,
    required this.age,
    required this.contactNumber,
    required this.aadharNumber,
    required this.personWithVehiclePhotoPath,
    required this.licensePhotoPath,
    required this.startDateTime,
    required this.endDateTime,
    required this.rentCharge,
    required this.deposit,
    this.status = 'active',
    this.actualReturnDateTime,
    this.rating,
  });

  bool get isOverdue =>
      status == 'active' && DateTime.now().isAfter(endDateTime);

  Rental copyWith({
    int? customerId,
    String? status,
    DateTime? actualReturnDateTime,
    int? rating,
  }) {
    return Rental(
      id: id,
      vehicleId: vehicleId,
      vehicleType: vehicleType,
      customerId: customerId ?? this.customerId,
      customerName: customerName,
      age: age,
      contactNumber: contactNumber,
      aadharNumber: aadharNumber,
      personWithVehiclePhotoPath: personWithVehiclePhotoPath,
      licensePhotoPath: licensePhotoPath,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      rentCharge: rentCharge,
      deposit: deposit,
      status: status ?? this.status,
      actualReturnDateTime: actualReturnDateTime ?? this.actualReturnDateTime,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleType': vehicleType.name,
      'customerId': customerId,
      'customerName': customerName,
      'age': age,
      'contactNumber': contactNumber,
      'aadharNumber': aadharNumber,
      'personWithVehiclePhotoPath': personWithVehiclePhotoPath,
      'licensePhotoPath': licensePhotoPath,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'rentCharge': rentCharge,
      'deposit': deposit,
      'status': status,
      'actualReturnDateTime': actualReturnDateTime?.toIso8601String(),
      'rating': rating,
    };
  }

  factory Rental.fromMap(Map<String, dynamic> map) {
    return Rental(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      vehicleType: VehicleTypeX.fromKey(map['vehicleType'] as String),
      customerId: map['customerId'] as int?,
      customerName: map['customerName'] as String,
      age: map['age'] as int,
      contactNumber: map['contactNumber'] as String,
      aadharNumber: map['aadharNumber'] as String,
      personWithVehiclePhotoPath: map['personWithVehiclePhotoPath'] as String,
      licensePhotoPath: map['licensePhotoPath'] as String,
      startDateTime: DateTime.parse(map['startDateTime'] as String),
      endDateTime: DateTime.parse(map['endDateTime'] as String),
      rentCharge: (map['rentCharge'] as num).toDouble(),
      deposit: (map['deposit'] as num).toDouble(),
      status: map['status'] as String,
      actualReturnDateTime: map['actualReturnDateTime'] != null
          ? DateTime.parse(map['actualReturnDateTime'] as String)
          : null,
      rating: map['rating'] as int?,
    );
  }
}
