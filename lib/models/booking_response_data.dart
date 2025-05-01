import 'dart:convert';

enum BookingStatus { PENDING, ONGOING, REJECTED, REACHED , ACCEPTED }

class BookingResponseDto {
  String pickupLocation;
  BookingStatus bookingStatus;
  DateTime date;
  DateTime time; // We'll use DateTime for both date and time separately
  String driverName;
  double rating;
  int driverId;

  BookingResponseDto({
    required this.pickupLocation,
    required this.bookingStatus,
    required this.date,
    required this.time,
    required this.driverName,
    required this.rating,
    required this.driverId
  });

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) {
    return BookingResponseDto(
      pickupLocation: json['pickupLocation'],
      bookingStatus: BookingStatus.values.firstWhere(
            (e) => e.name == json['bookingStatus'],
      ),
      date: DateTime.parse(json['date']),
      time: DateTime.parse('1970-01-01T${json['time']}'),
      driverName: json['driverName'],
      rating: (json['rating'] as num).toDouble(),
      driverId: json['driverId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupLocation': pickupLocation,
      'bookingStatus': bookingStatus.name,
      'date': date.toIso8601String().split('T').first,
      'time': time.toIso8601String().split('T').last,
      'driverName': driverName,
      'rating': rating,
      'driverId':driverId
    };
  }
}
