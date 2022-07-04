library maps_places_autocomplete;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';
import 'model/suggestion.dart';

class MapsPlacesAutocomplete extends HookWidget {
  final focusNode = FocusNode();
  final layerLink = LayerLink();
  final String sessionToken = const Uuid().v4();
  late TextEditingController _controller;
  late AddressService _addressService;
  OverlayEntry? entry;
  ValueNotifier<List<Suggestion>> _suggestions = ValueNotifier([]);
  final void Function(Place place, Suggestion suggestion) onSuggestionClick;

  //your maps api key, must not be null
  final String mapsApiKey;
  final String startText;

  //builder used to render each item displayed
  //must not be null
  final Widget Function(Suggestion, int) buildItem;

  //builder used to render a clear, it can be null, but in that case, a clear button is not displayed
  final Icon? clearButton;
  final Function()? clearButtonOnTap;

  final Icon? prefixIcon;
  final Function()? prefifxIconOnTap;

  //BoxDecoration for the suggestions external container
  final BoxDecoration? containerDecoration;
  //InputDecoration, if none is given, it defaults to flutter standards
  final InputDecoration? inputDecoration;

  //Elevation for the suggestion list
  final double? elevation;

  //Offset between the TextField and the Overlay
  final double overlayOffset;

  //if true, shows "powered by google" inside the suggestion list, after its items
  final bool showGoogleTradeMark;

  final bool autofocus;
  final bool usePlain;
  final bool isOverlay;

  final TextStyle? textStyle;

  //used to narrow down address search
  final String? componentCountry;

  //in witch language the results are being returned
  final String? language;

  late ValueNotifier<bool> isGettingDetails;
  late ValueNotifier<int> charUntilSearch;

  MapsPlacesAutocomplete(
      {Key? key,
      required this.onSuggestionClick,
      required this.mapsApiKey,
      required this.buildItem,
      this.usePlain = false,
      this.clearButton,
      this.containerDecoration,
      this.inputDecoration,
      this.startText = "",
      this.elevation,
      this.overlayOffset = 4,
      this.showGoogleTradeMark = true,
      this.isOverlay = false,
      this.autofocus = true,
      this.textStyle,
      this.componentCountry,
      this.language,
      this.clearButtonOnTap,
      this.prefixIcon,
      this.prefifxIconOnTap})
      : super(key: key);

  void showOverlay(BuildContext context) {
    final overlay = Overlay.of(context)!;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    entry = OverlayEntry(builder: (ctx) {
      return Positioned(
        width: size.width,
        child: CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + overlayOffset + 8),
            child: buildOverlay(ctx, size)),
      );
    });
    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void _clearText() {
    if (clearButtonOnTap != null) {
      clearButtonOnTap!();
    }
    _controller.clear();
    //focusNode.unfocus();
    _suggestions.value = [];
    charUntilSearch.value = 0;
    buildList();
    //_suggestions = [];
  }

  List<Widget> buildList() {
    List<Widget> list = [];
    for (int i = 0; i < _suggestions.value.length; i++) {
      Suggestion s = _suggestions.value[i];
      Widget w = InkWell(
        child: buildItem(s, i),
        onTap: () async {
          _controller.text = s.description;
          hideOverlay();
          focusNode.unfocus();
          isGettingDetails.value = true;
          Place place = await _addressService.getPlaceDetail(s.placeId,
              usePlain: usePlain);
          isGettingDetails.value = false;
          onSuggestionClick(place, s);
        },
      );
      list.add(w);
    }
    return list;
  }

  Widget buildOverlay(BuildContext context, Size size) => Material(
      color: containerDecoration != null ? Colors.transparent : Colors.white,
      elevation: elevation ?? 0,
      child: Container(
        alignment: Alignment.center,
        decoration: containerDecoration ?? const BoxDecoration(),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Visibility(
              visible: _controller.text.isNotEmpty,
              child: SizedBox(
                child: Container(
                  alignment: Alignment.center,
                  //height: 16,
                  width: size.width - 32,
                  //padding: const EdgeInsets.only(top: 6),
                  child: Center(
                    child: LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      value: charUntilSearch.value == 0 || isSearching.value
                          ? null
                          : charUntilSearch.value / 4,
                    ),
                  ),
                ),
              ),
            ),
            ...buildList(),
            if (showGoogleTradeMark)
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text("powered by google"),
              )
          ],
        ),
      ));

  String _lastText = "";
  Future<void> searchAddress(String text) async {
    if (text != _lastText && text != "") {
      _lastText = text;
      try {
        _suggestions.value =
            await _addressService.search(text, usePlain: usePlain);
      } catch (e) {
        error.value = e.toString();
      }
    }
  }

  InputDecoration getInputDecoration() {
    if (inputDecoration != null) {
      return inputDecoration!.copyWith(
          //contentPadding: EdgeInsets.zero,
          hintStyle:
              textStyle?.copyWith(color: textStyle?.color?.withOpacity(0.5)),
          suffixIcon: clearButton != null
              ? IconButton(
                  icon: clearButton!,
                  onPressed: _clearText,
                )
              : const SizedBox.shrink(),
          alignLabelWithHint: true,
          prefixIcon: prefixIcon != null
              ? IconButton(
                  icon: prefixIcon!,
                  onPressed: prefifxIconOnTap,
                )
              : null);
    }
    return const InputDecoration();
  }

  ValueNotifier<String> error = ValueNotifier('');
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    _controller = useTextEditingController(text: startText);
    isGettingDetails = useState(false);
    _suggestions = useState([]);
    isSearching = useState(false);
    charUntilSearch = useState(0);
    error = useState('');

    useEffect(() {
      //_controller = TextEditingController();
      _addressService =
          AddressService(sessionToken, mapsApiKey, componentCountry, language);
      isGettingDetails.value = false;
      charUntilSearch.value = 0;
      _suggestions.value = [];
      _controller.text = startText;

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          showOverlay(context);
        } else {
          hideOverlay();
        }
      });
      return () {};
    }, []);

    return isGettingDetails.value
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  'Getting details...',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            ),
          )
        : CompositedTransformTarget(
            link: layerLink,
            child: Stack(
              children: [
                TextField(
                    focusNode: focusNode,
                    controller: _controller,
                    autofocus: autofocus,
                    style: textStyle,
                    onChanged: (text) async {
                      charUntilSearch.value = text.length % 4;
                      if (text.isNotEmpty && text.length % 4 == 0) {
                        if (!isSearching.value) {
                          isSearching.value = true;
                          await searchAddress(text);
                          isSearching.value = false;
                        }
                      }
                    },
                    autocorrect: false,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    decoration: getInputDecoration().copyWith()),
              ],
            ),
          );
  }
}
