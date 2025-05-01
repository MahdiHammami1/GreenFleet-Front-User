class Location {
  final double latitude;
  final double longitude;
  final String nameLocation;

  Location({
    required this.latitude,
    required this.longitude,
    required this.nameLocation,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json['latitude'],
    longitude: json['longitude'],
    nameLocation: json['nameLocation'],
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'nameLocation': nameLocation,
  };
}