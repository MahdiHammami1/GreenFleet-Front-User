

class RideResponse {
  int rideId;
  int driverId;
  String driverName;
  String carName;
  double rateDriver;
  String stopoverName;
  String distanceBetween;
  List<String> prefrences; // not preferences

  RideResponse({
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.carName,
    required this.rateDriver,
    required this.stopoverName,
    required this.distanceBetween,
    required this.prefrences,
  });

  factory RideResponse.fromJson(Map<String, dynamic> json) {
    return RideResponse(
      rideId: json['rideId'],
      driverId: json['driverId'], // correct key
      driverName: json['driverName'],
      carName: json['carName'],
      rateDriver:  (json['rateDriver'] as num?)?.toDouble() ?? 0.0,
      stopoverName: json['stopoverName'],
      distanceBetween: json['distanceBetween'],
      prefrences: List<String>.from(json['prefrences']), // typo respected
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId':rideId,
      'driverId': driverId,
      'driverName': driverName,
      'carName': carName,
      'rateDriver': rateDriver,
      'stopoverName': stopoverName,
      'distanceBetween': distanceBetween,
      'prefrences': prefrences,
    };
  }
}
