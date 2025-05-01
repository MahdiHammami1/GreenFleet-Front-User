import '../dto/StopoverDTO.dart';
import 'location_data.dart';

class Stopovers {
  Location? location;
  String? stopoverStatus;

  Stopovers({
    this.location,
    this.stopoverStatus,
  });

  Stopovers.empty()
      : location = null,
        stopoverStatus = null;

  factory Stopovers.fromJson(Map<String, dynamic> json) => Stopovers(
    stopoverStatus: json['stopoverStatus'],
    location: json['location'] != null
        ? Location.fromJson({
      'latitude': json['latitude'],
      'longitude': json['longitude'],
      'nameLocation': json['name'],
    })
        : null,
  );

  Map<String, dynamic> toJson() => {
    "stopoverStatus": stopoverStatus,
    "latitude": location?.latitude,
    "longitude": location?.longitude,
    "name": location?.nameLocation,

  };


}