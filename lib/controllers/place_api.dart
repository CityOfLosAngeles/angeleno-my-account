//     flutter run -d chrome --web-port=50601 --dart-define-from-file=.env --web-browser-flag "--disable-web-security"
//firebase emulators:start --only functions
import 'dart:html';

//import 'package:dio/dio.dart';
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

    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$apiKey&sessiontoken=$sessionToken';

    String CORSproxy = '$fetchSuggestionsAPIFirebaseURL$request';

    Response? response;

    Map<String, String> headers = {
      'Content-Type': 'application/json', // Example header
    };

    try {
      if (isTestingLocally) {
        response = await http.get(Uri.parse(CORSproxy), headers: headers);
      } else {
        response = await http.get(Uri.parse(request), headers: headers);
      }
      // response = await http.get(Uri.parse(CORSproxy), headers: headers);
    } catch (e) {
      print('the issue we got ${e.toString()} ');
    }
    print(
        'the count of times we call the API is $count and sessionToken is $sessionToken');

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
      print('We got result message exception');
      throw Exception(result);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<AutofillPlace> getPlaceDetailFromId(final String placeId) async {
    print('\n==============================');
    print('We are in the getPlaceDetailFromId and the $placeId');
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
    String CORSproxy = '$placesAPIFirebaseURL$request';
    try {
      Response? response;
      //If we are testing locally, then let's use the Firebase URL, otherwise let's use te normal request url
      if (isTestingLocally) {
        response = await client.get(Uri.parse(CORSproxy));
      } else {
        response = await client.get(Uri.parse(request));
      }
      //final response = await client.get(Uri.parse(request));

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
            print('The place deTAIL IS ${place.toString()}');
            return place;
          } catch (e) {
            print('$e and the response is $response');
          }
        }
        print('Returning empty AutoFillPlace');
        print('The response is ${response.body}');
        return AutofillPlace();
      }
    } catch (e) {
      print('Error with requesting Suggestion $e');
    }
    return AutofillPlace();
  }
}
