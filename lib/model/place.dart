class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? state;
  String? zipCode;
  String? vicinity;
  String? country;
  double? lat;
  double? lng;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.vicinity,
    this.country,
    this.lat,
    this.lng,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, state: $state, zipCode: $zipCode, vicinity: $vicinity, country: $country, lat: $lat, lng: $lng)';
  }
}
