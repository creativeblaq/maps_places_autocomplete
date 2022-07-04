import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

class PlaceApiProvider {
  //final client = Client();

  PlaceApiProvider(
      this.sessionToken, this.mapsApiKey, this.compomentCountry, this.language);

  final String sessionToken;
  final String mapsApiKey;
  final String? compomentCountry;
  final String? language;

  Future<List<Suggestion>> fetchSuggestionsPlain(String input) async {
    print("CALLING PLAIN");
    final Map<String, dynamic> parameters = <String, dynamic>{
      'input': input,
      'types': 'address',
      'key': mapsApiKey,
      'sessiontoken': sessionToken
    };

    if (language != null) {
      parameters.addAll(<String, dynamic>{'language': language});
    }
    if (compomentCountry != null) {
      parameters
          .addAll(<String, dynamic>{'components': 'country:$compomentCountry'});
    }

    final Uri request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: '/maps/api/place/autocomplete/json',
        queryParameters: parameters);

    /*  final response = await client.get(request, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": 'GET',
    }); */

    final response = await Dio()
        .get("https://maps.googleapis.com/maps/api/place/autocomplete/json",
            queryParameters: parameters,
            options: Options(headers: {
              "Access-Control-Allow-Origin": "*",
              "Access-Control-Allow-Methods": 'GET',
            }));

    if (response.statusCode == 200) {
      //final result = json.decode(response.data);
      final result = response.data;

      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future callCloudFunction(
      {required String functionName,
      required Map<String, dynamic> params}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      functionName,
    );
    try {
      final HttpsCallableResult result = await callable.call(params);
      //print(result.data);
      return (result.data);
    } on FirebaseFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
      return null;
    } catch (e) {
      print('caught generic exception');
      print(e);
      return null;
    }
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'input': input,
      'types': 'address',
      'key': mapsApiKey,
      'sessiontoken': sessionToken,
    };

    if (language != null) {
      params.addAll(<String, dynamic>{'language': language});
    }
    if (compomentCountry != null) {
      params
          .addAll(<String, dynamic>{'components': 'country:$compomentCountry'});
    }
    final response = await callCloudFunction(
        functionName: 'maps-getSuggestions', params: params);

    if (response['status'] == "OK") {
      final data = List.from(response["predictions"]);
      return data
          .map((e) => Suggestion(e['place_id'], e['description']))
          .toList();
    } else {
      throw Exception('Failed to fetch suggestion ${response['status']}');
    }
  }

  Future<Place> getPlaceDetailFromIdPlain(String placeId) async {
    // if you want to get the details of the selected place by place_id
    print("PLAIN: PLACE DETAILS:");

    final Map<String, dynamic> parameters = <String, dynamic>{
      'place_id': placeId,
      'fields': 'address_component,geometry',
      'key': mapsApiKey,
      'sessiontoken': sessionToken
    };
    final Uri request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: '/maps/api/place/details/json',
        queryParameters: parameters);

    //print(request.toString());

    final response = await Dio().get(
        "https://maps.googleapis.com/maps/api/place/details/json",
        queryParameters: parameters);

    //print("PLAIN: DETAILS response: $response");

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'OK') {
        final components =
            result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();

        place.lat = result['result']['geometry']['location']['lat'] as double;
        place.lng = result['result']['geometry']['location']['lng'] as double;

        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
          }
          if (type.contains('sublocality_level_1')) {
            place.vicinity = c['long_name'];
          }
          if (type.contains('administrative_area_level_2')) {
            place.city = c['long_name'];
          }
          if (type.contains('administrative_area_level_1')) {
            place.state = c['long_name'];
          }
          if (type.contains('country')) {
            place.country = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        });
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    // if you want to get the details of the selected place by place_id
    final Map<String, dynamic> params = <String, dynamic>{
      'place_id': placeId,
      'fields': 'address_component,geometry',
      'key': mapsApiKey,
      'sessiontoken': sessionToken,
    };
    /* const String request =
        'https://maps.googleapis.com/maps/api/place/details/json';

    print(request.toString()); */

    /* final response = await Dio().get(request,
        queryParameters: parameters,
        options: Options(headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": 'GET',
        })); */

    final response = await callCloudFunction(
        functionName: 'maps-getDetails', params: params);

    if (response['status'] == 'OK') {
      final result = Map<String, dynamic>.from(response['result']);
      final components = result['address_components'] as List<dynamic>;
      // build result
      final place = Place();

      place.lat = result['geometry']['location']['lat'] as double;
      place.lng = result['geometry']['location']['lng'] as double;

      components.forEach((c) {
        final List type = c['types'];
        if (type.contains('street_number')) {
          place.streetNumber = c['long_name'];
        }
        if (type.contains('route')) {
          place.street = c['long_name'];
        }
        if (type.contains('sublocality_level_1')) {
          place.vicinity = c['long_name'];
        }
        if (type.contains('administrative_area_level_2')) {
          place.city = c['long_name'];
        }
        if (type.contains('administrative_area_level_1')) {
          place.state = c['long_name'];
        }
        if (type.contains('country')) {
          place.country = c['long_name'];
        }
        if (type.contains('postal_code')) {
          place.zipCode = c['long_name'];
        }
      });
      return place;
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
