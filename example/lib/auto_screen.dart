import 'package:example/address_model.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/maps_places_autocomplete.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  AddressModel? selectedAdddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(selectedAdddress?.fullAddress ?? "No Address"),
            ElevatedButton(
                onPressed: () async {
                  final res = await PlacesAutocompleteDialog.show(context);
                  if (res != null) {
                    setState(() {
                      selectedAdddress = res;
                    });
                  }
                },
                child: Text('Start search')),
          ],
        ),
      ),
    );
  }
}

class PlacesAutocompleteDialog extends StatelessWidget {
  const PlacesAutocompleteDialog({Key? key, this.startText}) : super(key: key);
  final String? startText;

  static Future<AddressModel?> show(BuildContext context,
      {String? startText}) async {
    final address = await showDialog(
        context: context,
        builder: (context) => PlacesAutocompleteDialog(
              startText: startText,
            ));
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 32,
            left: 8,
            right: 8,
            child: PlacesAutoCompleteSearchBar(
              startText: startText,
            ),
          ),
        ],
      ),
    );
  }
}

class PlacesAutoCompleteSearchBar extends StatelessWidget {
  const PlacesAutoCompleteSearchBar({
    Key? key,
    this.startText,
  }) : super(key: key);
  final String? startText;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      //borderSide: BorderSide(color: SHColors.primaryLight, width: 0.5),
    );
    return Card(
      //color: SHColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6.0,
      margin: const EdgeInsets.only(top: 16),
      child: Center(
        child: MapsPlacesAutocomplete(
          prefixIcon: Icon(
            Icons.chevron_left,
            //color: SHColors.iconColorLight,
            size: 20,
          ),
          usePlain: true,
          isOverlay: true,
          startText: startText ?? "",
          prefifxIconOnTap: () => Navigator.pop(context),
          searchMinChar: 2,
          mapsApiKey: mapsKey,
          //textStyle: SHTextTheme.body(),
          inputDecoration: InputDecoration(
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            isDense: true,
            hintText: 'Search Your Location',
            //hintStyle: SHTextTheme.body(color: SHColors.iconColorLight),
          ),
          showGoogleTradeMark: false,
          onSuggestionClick: (Place p, Suggestion s) {
            String address = p.streetNumber ?? "";
            address += " ${p.street ?? ""}";
            address += ", ${p.vicinity ?? ""}";
            address += ", ${p.city ?? ""}";
            address += ", ${p.state ?? ""}";
            address += ", ${p.country ?? ""}";
            address += ", ${p.zipCode ?? ""}";
            /*  location.setAddress(address);
            location.setLat(p.lat);
            location.setLng(p.lng);
            pop(context); */
            final AddressModel addressModel = AddressModel(
                placeId: s.placeId,
                streetNumber: p.streetNumber ?? "",
                street: p.street ?? "",
                city: p.city ?? "",
                postalCode: p.zipCode ?? "",
                fullAddress: address,
                location: GeoPoint(p.lat ?? 0.0, p.lng ?? 0.0),
                createdAt: DateTime.now());
            Navigator.pop(context, addressModel);
          },
          componentCountry: 'za',
          clearButton: Icon(
            Icons.close,
            //color: SHColors.iconColorLight,
          ),
          containerDecoration: BoxDecoration(
              //color: SHColors.primaryDark,
              borderRadius: BorderRadius.circular(16)),
          language: 'en',
          buildItem: (suggestion, index) {
            return Card(
                //color: SHColors.primary,
                margin: EdgeInsets.only(top: index == 0 ? 12 : 4, bottom: 12),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(
                    suggestion.description,
                  ),
                ));
          },
        ),
      ),
    );
  }
}
