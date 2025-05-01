

enum BookingStatus { PENDING, ONGOING, REJECTED, REACHED }

class Booked {
  int? passengerId;
  int? rideId;
  String? feedback;
  double? rating;
  BookingStatus? bookingStatus;
  String? pickupLocation;

  Booked({
    this.passengerId,
    this.rideId,
    this.feedback,
    this.rating,
    this.bookingStatus,
    this.pickupLocation,
  });
  Booked.initial({
    required int passengerId,
    required int rideId,
    required String pickupLocation,
  }) :
        passengerId = passengerId,
        rideId = rideId,
        pickupLocation = pickupLocation,
        feedback = null,
        rating = null,
        bookingStatus = BookingStatus.PENDING;


  factory Booked.fromJson(Map<String, dynamic> json) {
    return Booked(
      passengerId: json['passengerId'],
      rideId: json['rideId'],
      feedback: json['feedback'],
      rating: (json['rating'] != null) ? json['rating'].toDouble() : null,
      bookingStatus: json['bookingStatus'] != null
          ? BookingStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['bookingStatus'])
          : null,
      pickupLocation: json['pickupLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerId': passengerId,
      'rideId': rideId,
      'feedback': feedback,
      'rating': rating,
      'bookingStatus': bookingStatus?.toString().split('.').last,
      'pickupLocation': pickupLocation,
    };
  }
}
