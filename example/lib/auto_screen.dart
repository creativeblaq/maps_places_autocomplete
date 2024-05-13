import 'package:maps_places_autocomplete/model/address_model.dart';
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
                  final res = await PlacesAutocompleteDialog.show(context,
                      mapsKey: mapsKey);
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
