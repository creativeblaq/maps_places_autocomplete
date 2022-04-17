This is a simple implementation of google maps places autocomplete.

## Features

List suggestions of places by search
O click get place details mapped

## Getting started

A complete sample of use inside example folder

## Usage

Look at example folder main an example of use
to `/example` folder. 


import the lim and model
```dart
import 'package:maps_places_autocomplete/maps_places_autocomplete.dart';
import 'package:maps_places_autocomplete/model/place.dart';
```

write a callback function
```dart
void onSuggestionClick(Place placeDetails) {
    setState(() {
      _streetNumber = placeDetails.streetNumber;
      _street = placeDetails.street;
      _city = placeDetails.city;
      _state = placeDetails.state;
      _zipCode = placeDetails.zipCode;
      _country = placeDetails.country;
      _vicinity = placeDetails.vicinity;
      _lat = placeDetails.lat;
      _lng = placeDetails.lng;
    });
  }
```

include the package widget, configure language and country restriction
languange and country are optional
insert your google places api key
```dart
MapsPlacesAutocomplete(
    mapsApiKey: 'YOUR KEY HERE',
    onSuggestionClick: onSuggestionClick,
    componentCountry: 'br',
    language: 'pt-BR'
),
```

## Additional information

This package implements the oficial documention of google maps places api
and use address as types and receive a detail with address_component and geometry as fields only
