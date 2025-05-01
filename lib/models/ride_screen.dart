import 'package:flutter/material.dart';
import '../dto/RideDTO.dart';
import 'stopover_data.dart';


class RideData {
  int? rideId;
  int? driverId;
  int? carId;
  DateTime? rideDate;
  TimeOfDay? rideTime;
  int? numberOfSeat;
  bool published;
  List<Stopovers> stopovers;
  List<String> preferences;

  RideData({
    this.rideId,
    this.driverId,
    this.carId,
    this.rideDate,
    this.rideTime,
    this.numberOfSeat,
    this.published = false,
    List<Stopovers>? stopovers,
    List<String>? preferences,
  })  : stopovers = stopovers ?? [],
        preferences = preferences ?? [];

  RideData.empty()

      : rideId=null,
        driverId = null,
        carId = null,
        rideDate = null,
        rideTime = null,
        numberOfSeat = null,
        published = false,
        stopovers = [],
        preferences = [];

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
    rideId: json['rideId'],
    driverId: json['driverId'],
    carId: json['carId'],
    rideDate: json['rideDate'] != null
        ? DateTime.parse(json['rideDate'])
        : null,
    rideTime: json['rideTime'] != null
        ? TimeOfDay(
      hour: int.parse(json['rideTime'].split(':')[0]),
      minute: int.parse(json['rideTime'].split(':')[1]),
    )
        : null,
    numberOfSeat: json['numberOfSeat'],
    published: json['published'] ?? false,
    stopovers: (json['stopovers'] as List<dynamic>?)
        ?.map((item) => Stopovers.fromJson(item))
        .toList() ??
        [],
    preferences: (json['preferences'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'rideId': rideId,
    'driverId': driverId,
    'carId': carId,
    'rideDate': rideDate != null
        ? '${rideDate!.year.toString().padLeft(4, '0')}-${rideDate!.month.toString().padLeft(2, '0')}-${rideDate!.day.toString().padLeft(2, '0')}'
        : null,
    'rideTime': rideTime != null
        ? '${rideTime!.hour.toString().padLeft(2, '0')}:${rideTime!.minute.toString().padLeft(2, '0')}'
        : null,
    'numberOfSeat': numberOfSeat,
    'published': published,
    'stopovers': stopovers.map((e) => e.toJson()).toList(),
    'preferences': preferences,
  };


}