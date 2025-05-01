class VehicleDTO {
  final int vehicleId;
  final int licenceNumber;
  final String brand;
  final String model;
  final int numberOfSeat;
  final String registrationDate;
  final String pictureUrl;
  final int ownerId;

  VehicleDTO({
    required this.vehicleId,
    required this.licenceNumber,
    required this.brand,
    required this.model,
    required this.numberOfSeat,
    required this.registrationDate,

    required this.pictureUrl,
    required this.ownerId,
  });

  // Method to map from JSON to VehicleDTO
  factory VehicleDTO.fromJson(Map<String, dynamic> json) {
    return VehicleDTO(
      vehicleId: json['vehicleId'],
      licenceNumber: json['licenceNumber'],
      brand: json['brand'],
      model: json['model'],
      numberOfSeat: json['numberOfSeat'],
      registrationDate: json['registrationDate'],
      pictureUrl: json['pictureUrl'],
      ownerId: json['ownerId'],
    );
  }
}
