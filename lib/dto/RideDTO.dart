import '../models/request_booking_data.dart';
import 'StopoverDTO.dart';

class RideDTO {
  final int rideId;
  final String rideDate;
  final String rideTime;
  final int numberOfSeat;
  final bool published;
  final int availableSeats;
  final String carId;
  final List<String> preferences;
  final List<StopoverDTO> stopovers;
  final List<RequestBooking> booking;

  RideDTO({
    required this.rideId,
    required this.rideDate,
    required this.rideTime,
    required this.numberOfSeat,
    required this.published,
    required this.availableSeats,
    required this.carId,
    required this.preferences,
    required this.stopovers,
    required this.booking
  });

  factory RideDTO.fromJson(Map<String, dynamic> json) {
    return RideDTO(
      rideId: json['rideId'],
      rideDate: json['rideDate'],
      rideTime: json['rideTime'],
      numberOfSeat: json['numberOfSeat'],
      published: json['published'],
      availableSeats: json['availableSeats'],
      carId: json['carId'].toString(),
      preferences: List<String>.from(json['preferences']),
      stopovers: (json['stopovers'] as List).map((e) => StopoverDTO.fromJson(e)).toList(),
      booking: (json['booking'] as List?)?.map((e) => RequestBooking.fromJson(e)).toList() ?? [],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'rideDate': rideDate,
      'rideTime': rideTime,
      'numberOfSeat': numberOfSeat,
      'published': published,
      'availableSeats': availableSeats,
      'carId': carId,
      'preferences': preferences,
      'stopovers': stopovers.map((e) => e.toJson()).toList(),
      'RequestBooking':booking.map((e) => e.toJson()).toList
    };
  }
}
