class StopoverDTO {
  final String stopoverStatus;
  final double latitude;
  final double longitude;
  final String name;

  StopoverDTO({
    required this.stopoverStatus,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory StopoverDTO.fromJson(Map<String, dynamic> json) {
    return StopoverDTO(
      stopoverStatus: json['stopoverStatus'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stopoverStatus': stopoverStatus,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }
}
