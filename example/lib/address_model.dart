import 'dart:convert';

class AddressModel {
  String placeId;
  String streetNumber;
  String street;
  String city;
  String postalCode;
  String fullAddress;
  GeoPoint location;
  DateTime createdAt;

//<editor-fold desc="Data Methods">

  AddressModel({
    required this.placeId,
    required this.streetNumber,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.fullAddress,
    required this.location,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressModel &&
        other.placeId == placeId &&
        other.streetNumber == streetNumber &&
        other.street == street &&
        other.city == city &&
        other.postalCode == postalCode &&
        other.fullAddress == fullAddress &&
        other.location == location &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return placeId.hashCode ^
        streetNumber.hashCode ^
        street.hashCode ^
        city.hashCode ^
        postalCode.hashCode ^
        fullAddress.hashCode ^
        location.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'AddressModel(placeId: $placeId, streetNumber: $streetNumber, street: $street, city: $city, postalCode: $postalCode, fullAddress: $fullAddress, location: $location, createdAt: $createdAt)';
  }

  AddressModel copyWith({
    String? placeId,
    String? streetNumber,
    String? street,
    String? city,
    String? postalCode,
    String? fullAddress,
    GeoPoint? location,
    DateTime? createdAt,
  }) {
    return AddressModel(
      placeId: placeId ?? this.placeId,
      streetNumber: streetNumber ?? this.streetNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'streetNumber': streetNumber,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
      '_geoloc': {"lat": location.lat, "lng": location.lon},
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'streetNumber': streetNumber,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
      '_geoloc': {"lat": location.lat, "lng": location.lon},
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AddressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AddressModel(
      placeId: map['placeId'] ?? "",
      streetNumber: map['streetNumber'] ?? "",
      street: map['street'] ?? "",
      city: map['city'] ?? "",
      postalCode: map['postalCode'] ?? "",
      fullAddress: map['fullAddress'] ?? "",
      location: map['_geoloc'] != null
          ? GeoPoint(map['_geoloc']['lat'], map['_geoloc']['lng'])
          : const GeoPoint(0.00, 0.00),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  factory AddressModel.empty() {
    return AddressModel(
        placeId: 'placeId',
        streetNumber: "streetNumber",
        street: "street",
        city: "city",
        postalCode: "postalCode",
        fullAddress: "fullAddress",
        location: const GeoPoint(0.0, 0.0),
        createdAt: DateTime.now());
  }
}

class GeoPoint {
  final double lat, lon;

  const GeoPoint(this.lat, this.lon);
}
