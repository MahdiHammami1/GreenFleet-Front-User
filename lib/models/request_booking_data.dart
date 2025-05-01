class RequestBooking { // Booking 
  int? rideId;
  String? passengerName;
  int? passengerId;
  double? passengerRate;
  String? stopoverName;
  String? bookingStatus;
  RequestBooking({
    this.rideId,
    this.passengerName,
    this.passengerId,
    this.passengerRate,
    this.stopoverName,
    this.bookingStatus
  });

  RequestBooking.initial({
    required int rideId,
    required String passengerName,
    required int passengerId,
    required double passengerRate,
    required String stopoverName,
    required String bookingStatus
  })  : rideId = rideId,
        passengerName = passengerName,
        passengerId = passengerId,
        passengerRate = passengerRate,
        stopoverName = stopoverName,
        bookingStatus=bookingStatus;

  factory RequestBooking.fromJson(Map<String, dynamic> json) {
    return RequestBooking(
      rideId: json['rideId'],
      passengerName: json['passengerName'],
      passengerId: json['passengerId'],
      passengerRate: (json['passengerRate'] != null) ? json['passengerRate'].toDouble() : null,
      stopoverName: json['stopoverName'],
      bookingStatus: json['bookingStatus']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'passengerName': passengerName,
      'passengerId': passengerId,
      'passengerRate': passengerRate,
      'stopoverName': stopoverName,
      'bookingStatus':bookingStatus
    };
  }
}
