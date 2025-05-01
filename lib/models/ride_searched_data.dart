
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'location_data.dart';
import 'package:intl/intl.dart';
class Car {
  String model;
  int age;

  Car({required this.model, required this.age});

  // No-argument constructor with default values
  Car.empty() : this(model: '', age: 0);

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'age': age,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      model: json['model'],
      age: json['age'],
    );
  }
}

enum AlternativeType { taxi, moto, bus, car, others }

class RideSearchedData {
  Location fromLocation;
  DateTime date;
  TimeOfDay time;
  double rayonPossible;
  AlternativeType? alternativeType;
  Car? car;

  RideSearchedData({
    required this.fromLocation,
    required this.date,
    required this.time,
    required this.rayonPossible,
    this.alternativeType,
    this.car,
  });

  // No-argument constructor with default values
  RideSearchedData.empty()
      : fromLocation = Location(
    nameLocation: '',
    latitude: 0,
    longitude: 0,
  ),
        date = DateTime.now(),
        time = TimeOfDay.now(),
        rayonPossible = 1.0,
        alternativeType = null,
        car = null;

// In your ride_searched_data.dart file, modify the toJson method:

  Map<String, dynamic> toJson() {
    return {
      'fromLocation': {
        'name': fromLocation.nameLocation,
        'latitude': fromLocation.latitude,
        'longitude': fromLocation.longitude,
      },
      'date': DateFormat('yyyy-MM-dd').format(date),  // Format for LocalDate
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',  // Format for LocalTime
      'rayonPossible': rayonPossible,  // Convert to integer meters
      'alternativeType': alternativeType?.toString().split('.').last.toUpperCase(),
      'car': car?.toJson(),
    };
  }

  factory RideSearchedData.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return RideSearchedData(
      fromLocation: Location(
        nameLocation: json['fromLocation']['name'],
        latitude: json['fromLocation']['latitude'],
        longitude: json['fromLocation']['longitude'],
      ),
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      rayonPossible: json['rayonPossible'],
      alternativeType: json['alternativeType'] != null
          ? AlternativeType.values.firstWhere(
            (e) => e.toString().split('.').last == json['alternativeType'],
      )
          : null,
      car: json['car'] != null ? Car.fromJson(json['car']) : null,
    );
  }
}
