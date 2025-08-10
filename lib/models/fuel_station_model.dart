class FuelStation {
  final String? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? distance;
  final String? category;
  final String? icon;
  final double? rating;
  final List<String>? openingHours;

  FuelStation({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.category,
    this.icon,
    this.rating,
    this.openingHours,
  });

  factory FuelStation.fromJson(Map<String, dynamic> json) {
    return FuelStation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distance: json['distance'],
      category: json['category'],
      icon: json['icon'],
      rating: json['rating']?.toDouble(),
      openingHours: json['openingHours'] != null 
          ? List<String>.from(json['openingHours'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'category': category,
      'icon': icon,
      'rating': rating,
      'openingHours': openingHours,
    };
  }
}

class FuelStationsResponse {
  final String? result;
  final String? responseMsg;
  final List<FuelStation>? fuelStations;

  FuelStationsResponse({
    this.result,
    this.responseMsg,
    this.fuelStations,
  });

  factory FuelStationsResponse.fromJson(Map<String, dynamic> json) {
    return FuelStationsResponse(
      result: json['Result'],
      responseMsg: json['ResponseMsg'],
      fuelStations: json['fuelStations'] != null
          ? List<FuelStation>.from(
              json['fuelStations'].map((x) => FuelStation.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result,
      'ResponseMsg': responseMsg,
      'fuelStations': fuelStations?.map((x) => x.toJson()).toList(),
    };
  }
}
