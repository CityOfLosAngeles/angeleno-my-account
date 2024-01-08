//     flutter run -d chrome --web-port=50601 --dart-define-from-file=.env --web-browser-flag "--disable-web-security"

import 'dart:html';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
//import 'dart:io';
import 'dart:convert';
import '../models/autofill_place.dart';
import '../models/autofill_suggestion.dart';
import '../utils/constants.dart';

class PlaceAPI {
  final client = Client();
  String sessionToken;
  PlaceAPI(this.sessionToken);

  int count = 0;

  final apiKey = placesAPI;

  Future<List<AutofillSuggestion>> fetchSuggestions(
      final String input, final String lang) async {
    List<AutofillSuggestion> places = [];
    //print(
    //  'Our Session token for Places API is $sessionToken with input and lan $input/$lang');
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    Response? response;
    //print('the request is $request');

    try {
      response = await http.get(Uri.parse(request));
    } catch (e) {
      print(e.toString());
    }
    //count++;
    print(
        'the count of times we call the API is $count and sessionToken is $sessionToken');
    //print('client Our response is ${json.decode(response!.body)}');
    // print('client The link is $request');

    if (response!.statusCode == 200) {
      final result = json.decode(response!.body);
      if (result['status'] == 'OK') {
        places = result['predictions']
            .map<AutofillSuggestion>((p) => AutofillSuggestion(
                p['place_id'] as String,
                p['description'] as String,
                p['structured_formatting']['main_text'] as String))
            .toList() as List<AutofillSuggestion>;
        return places;
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<AutofillPlace> getPlaceDetailFromId(final String placeId) async {
    print('\n==============================');
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        try {
          final components =
              result['result']['address_components'] as List<dynamic>;
          // build result
          final place = AutofillPlace();
          for (final c in components) {
            List type = c['types'] as List;

            if (type.contains('street_number')) {
              // print('pazSTREET# ${c['long_name'] as String}');
              place.streetNumber = c['long_name'] as String;
            }
            if (type.contains('route')) {
              // print('pazSTREET ${c['long_name'] as String}');
              place.street = c['long_name'] as String;
            }
            if (type.contains('locality')) {
              // print('pazCITY ${c['long_name'] as String}');
              place.city = c['long_name'] as String;
            }
            if (type.contains('postal_code')) {
              //print('pazZIP ${c['long_name'] as String}');
              place.zipCode = c['long_name'] as String;
            }
            if (type.contains('administrative_area_level_1')) {
              // print('pazSTATE ${c['long_name'] as String}');
              place.state = c['long_name'] as String;
            }
          }
          return place;
        } catch (e) {
          print('$e and the response is $response');
        }
      }
      return AutofillPlace();
      //throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
