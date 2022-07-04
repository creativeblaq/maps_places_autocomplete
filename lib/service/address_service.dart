import 'package:maps_places_autocomplete/api/place_api_provider.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

class AddressService {
  AddressService(this.sessionToken, this.mapsApiKey, this.componentCountry,
      this.language) {
    apiClient =
        PlaceApiProvider(sessionToken, mapsApiKey, componentCountry, language);
  }

  final String sessionToken;
  final String mapsApiKey;
  final String? componentCountry;
  final String? language;
  late PlaceApiProvider apiClient;

  Future<List<Suggestion>> search(String query,
      {required bool usePlain}) async {
    if (usePlain) {
      return await apiClient.fetchSuggestionsPlain(query);
    } else {
      return await apiClient.fetchSuggestions(query);
    }
  }

  Future<Place> getPlaceDetail(String placeId, {required bool usePlain}) async {
    if (usePlain) {
      return await apiClient.getPlaceDetailFromIdPlain(placeId);
    } else {
      return await apiClient.getPlaceDetailFromId(placeId);
    }
    //return placeDetails;
  }
}
