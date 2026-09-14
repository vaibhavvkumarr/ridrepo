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

  /// Brands shown as suggestions while typing a vehicle's model. Covers
  /// major manufacturers across regions (India, US, Europe, Japan, Korea,
  /// China) since managers anywhere in the world may use this app.
  List<String> get brandSuggestions {
    switch (this) {
      case VehicleType.bike:
        return const [
          'Aprilia',
          'Ather',
          'Bajaj',
          'Benelli',
          'BMW Motorrad',
          'CFMoto',
          'Ducati',
          'Harley Davidson',
          'Hero',
          'Honda',
          'Husqvarna',
          'Indian Motorcycle',
          'Kawasaki',
          'KTM',
          'Kymco',
          'Moto Guzzi',
          'Ola Electric',
          'Piaggio',
          'Royal Enfield',
          'Suzuki',
          'SYM',
          'Triumph',
          'TVS',
          'Vespa',
          'Yadea',
          'Yamaha',
          'Zero Motorcycles',
        ];
      case VehicleType.car:
        return const [
          'Acura',
          'Alfa Romeo',
          'Aston Martin',
          'Audi',
          'Bentley',
          'BMW',
          'Buick',
          'BYD',
          'Cadillac',
          'Chery',
          'Chevrolet',
          'Chrysler',
          'Citroën',
          'Dodge',
          'Ferrari',
          'Fiat',
          'Ford',
          'Geely',
          'GMC',
          'Great Wall Motors',
          'Honda',
          'Hyundai',
          'Infiniti',
          'Jaguar',
          'Jeep',
          'Kia',
          'Lamborghini',
          'Land Rover',
          'Lexus',
          'Lincoln',
          'Mahindra',
          'Maruti Suzuki',
          'Maserati',
          'Mazda',
          'Mercedes-Benz',
          'MG',
          'Mini',
          'Mitsubishi',
          'Nissan',
          'Opel',
          'Peugeot',
          'Porsche',
          'Proton',
          'Ram',
          'Renault',
          'Rolls-Royce',
          'SEAT',
          'Škoda',
          'Subaru',
          'Suzuki',
          'Tata',
          'Tesla',
          'Toyota',
          'Volkswagen',
          'Volvo',
        ];
      case VehicleType.auto:
        return const [
          'Atul',
          'Bajaj',
          'Dayang',
          'Force Motors',
          'Lifan',
          'Mahindra',
          'Piaggio',
          'TVS',
        ];
      case VehicleType.bus:
        return const [
          'Ashok Leyland',
          'Blue Bird',
          'BYD',
          'Eicher',
          'Force',
          'Hino',
          'Isuzu',
          'Iveco',
          'King Long',
          'Mahindra',
          'MAN',
          'Mercedes-Benz',
          'Mitsubishi Fuso',
          'New Flyer',
          'Scania',
          'Setra',
          'Tata',
          'Van Hool',
          'Volvo',
          'Yutong',
        ];
      case VehicleType.truck:
        return const [
          'Ashok Leyland',
          'BharatBenz',
          'DAF',
          'Dongfeng',
          'Eicher',
          'FAW',
          'Ford',
          'Freightliner',
          'Hino',
          'International',
          'Isuzu',
          'Iveco',
          'Kenworth',
          'Mack',
          'Mahindra',
          'MAN',
          'Mercedes-Benz',
          'Mitsubishi Fuso',
          'Peterbilt',
          'Renault Trucks',
          'Scania',
          'Sinotruk',
          'Tata',
          'Volvo',
          'Western Star',
        ];
      case VehicleType.others:
        return const [
          'Bobcat',
          'Case',
          'Caterpillar',
          'Doosan',
          'Escorts',
          'Hitachi',
          'Hyundai Construction',
          'JCB',
          'John Deere',
          'Kobelco',
          'Komatsu',
          'Kubota',
          'L&T',
          'Liebherr',
          'Mahindra',
          'Manitou',
          'New Holland',
          'SANY',
          'Terex',
          'Volvo Construction',
          'XCMG',
        ];
    }
  }

  static VehicleType fromKey(String key) {
    return VehicleType.values.firstWhere(
      (t) => t.name == key,
      orElse: () => VehicleType.bike,
    );
  }
}
