// ignore: avoid_web_libraries_in_flutter
//import 'dart:html';
//Needed to declare this as there was an error with another library - material.dart

import 'dart:async';
import 'dart:html' as html;

import 'package:angeleno_project/controllers/place_api.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/models/autofill_place.dart';
import 'package:angeleno_project/models/autofill_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/api_implementation.dart';
import '../../controllers/overlay_provider.dart';
import '../../models/user.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late OverlayProvider overlayProvider;
  late UserProvider userProvider;
  late User user;

  TextEditingController usrAddressTextController = TextEditingController();
  TextEditingController usrCityTextController = TextEditingController();
  TextEditingController usrStateTextController = TextEditingController();
  TextEditingController usrZipTextController = TextEditingController();

  String sessionToken = "";
  //This is needed since the user becomes overwritten to original user data. But if we check the autofill
  bool autoFilled = false;
  List<AutofillSuggestion> suggestions = [];
  late PlaceAPI apiClient;

  @override
  void initState() {
    super.initState();
    sessionToken = Uuid().v4(); //Create token for the session
    apiClient = PlaceAPI(sessionToken);

    //loadAddress();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    overlayProvider = context.watch<OverlayProvider>();
    userProvider = context.watch<UserProvider>();
    loadUser();
  }

  @override
  void dispose() {
    usrAddressTextController.dispose();
    usrCityTextController.dispose();
    usrStateTextController.dispose();
    usrZipTextController.dispose();
    super.dispose();
  }

  void updateUser() {
    overlayProvider.showLoading();

    // Only submit patch if data has been updated
    if (!(user == userProvider.cleanUser)) {
      UserApi().updateUser(user).then((final response) {
        final success = response == html.HttpStatus.ok;
        overlayProvider.hideLoading();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 280.0,
            content: Text(success ? 'User updated' : 'User update failed'),
            action: success
                ? null
                : SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      updateUser();
                    })));
      });
    }
  }

  void loadAddress() {
    print('Loading Address');
    try {
      usrAddressTextController.text = user.address!;
      usrCityTextController.text = user.city!;
      usrStateTextController.text = user.state!;
      usrZipTextController.text = user.zip!;
    } catch (e) {
      print('Cannot load address $e');
    }
  }

  void loadUser() {
    if (userProvider.user == null) {
      //return const LinearProgressIndicator();
      print('user is null');
    } else {
      user = userProvider.user!;
      if (!autoFilled) {
        loadAddress();
      }
    }
  }

  Future<List<AutofillSuggestion>> fetchSuggestions(final String input) async {
    // Implement API call to fetch suggestions based on input
    apiClient.count++;
    return await apiClient.fetchSuggestions(
        input, Localizations.localeOf(context).languageCode);
  }
/*
  Future<AutofillPlace> getAutofillFullAddress(
      final AutofillSuggestion autocomplete) async {
    print('The autocomplete request to send to the API $autocomplete');

    //return AutofillPlace();
    return await PlaceAPI(sessionToken)
        .getPlaceDetailFromId(autocomplete.placeId!);
  }*/

  Future<void> onSuggestionSelected(final AutofillSuggestion sugg) async {
    print('We are in onSuggestionSelected with suggestion: ${sugg.toString()}');
    autoFilled = true;
    AutofillPlace place = AutofillPlace();
    try {
      usrAddressTextController.clear();
      usrAddressTextController.text = sugg.streetAddress!;
      place = await PlaceAPI(sessionToken).getPlaceDetailFromId(sugg.placeId!);
    } catch (e) {
      print('The autofillPlace error is $e');
    }

    try {
      user.city = place.city;
      user.zip = place.zipCode;
      user.state = place.state;
      user.address = sugg.streetAddress;
      //user.address2 =
      usrCityTextController.text = place.city!;
      usrStateTextController.text = place.state!;
      usrZipTextController.text = place.zipCode!;
    } catch (e) {
      print('The error is $e');
    }

//We need this for the Autofill to become active after selecting and saving as the issue made the suggestion keep re-apperaring
    Future.delayed(const Duration(milliseconds: 1234), () {
      setState(() {
        autoFilled = false;
        apiClient.count = 0;
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    if (userProvider.user == null) {
      return const LinearProgressIndicator();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Form(
                      key: formKey,
                      onChanged: () {
                        formKey.currentState!.save();
                      },
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          const SizedBox(height: 10.0),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (userProvider.isEditing) {
                                      updateUser();
                                    }
                                    setState(() {
                                      userProvider.toggleEditing();
                                    });
                                  },
                                  child: Text(
                                      userProvider.isEditing ? 'Save' : 'Edit'),
                                ),
                                if (userProvider.isEditing)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        userProvider.toggleEditing();
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  )
                              ]),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: userProvider.isEditing,
                            decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder()),
                            initialValue: user.firstName,
                            keyboardType: TextInputType.name,
                            onChanged: (final val) {
                              user.firstName = val;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: userProvider.isEditing,
                            decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder()),
                            initialValue: user.lastName,
                            keyboardType: TextInputType.name,
                            onChanged: (final val) {
                              user.lastName = val;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          TypeAheadField<AutofillSuggestion>(
                              controller: usrAddressTextController,
                              // suggestionsCallback: (search) => CityService.of(context).find(search),
                              debounceDuration:
                                  const Duration(milliseconds: 555),
                              hideOnEmpty: true,
                              hideOnLoading: true,
                              suggestionsCallback: (search) async {
                                //At initial, if the widget is called, it show suggestions but we should avoid at ommit, so...
                                bool isInitial = user.address ==
                                    usrAddressTextController.text;
                                try {
                                  if (search.isEmpty ||
                                      autoFilled ||
                                      isInitial) {
                                    // print('Show nothing');
                                    return [];
                                  } else {
                                    final cities =
                                        await fetchSuggestions(search);
                                    //print('Show cities');
                                    return cities;
                                  }
                                } catch (error) {
                                  // Handle errors here
                                  print(error);
                                  return []; // Return an empty list in case of errors
                                }
                              },
                              builder: (context, controller, focusNode) =>
                                  TextField(
                                    enabled: userProvider.isEditing,
                                    controller: controller,
                                    focusNode: focusNode,
                                    //autofocus: false,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            usrAddressTextController.clear();
                                          },
                                        ),
                                        labelText: 'Address',
                                        border: OutlineInputBorder()),
                                  ),
                              itemBuilder: (context, address) => ListTile(
                                    title: Text(address.description!),
                                    subtitle: Text(address.streetAddress!),
                                  ),
                              onSelected: onSuggestionSelected),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: userProvider.isEditing,
                            decoration: const InputDecoration(
                                labelText: 'Address 2',
                                //border: InputBorder.none,
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.streetAddress,
                            initialValue: user.address2,
                            onChanged: (final val) {
                              user.address2 = val;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: false,
                            controller: usrCityTextController,
                            decoration: const InputDecoration(
                                labelText: 'City', border: InputBorder.none
                                // border: OutlineInputBorder()
                                ),
                            keyboardType: TextInputType.streetAddress,
                            //initialValue: user.city,
                            onChanged: (final val) {
                              user.city = val;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: false,
                            controller: usrZipTextController,
                            decoration: const InputDecoration(
                              labelText: 'Zip', border: InputBorder.none,
                              //border: OutlineInputBorder()
                            ),
                            //initialValue: user.zip,
                            onChanged: (final val) {
                              user.zip = val;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: false,
                            controller: usrStateTextController,
                            decoration: const InputDecoration(
                                labelText: 'State', border: InputBorder.none
                                // border: OutlineInputBorder()
                                ),
                            keyboardType: TextInputType.streetAddress,
                            //initialValue: user.state,
                            onChanged: (final val) {
                              user.state = val;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: userProvider.isEditing,
                            decoration: const InputDecoration(
                                labelText: 'Mobile',
                                border: OutlineInputBorder()),
                            initialValue: user.phone,
                            onChanged: (final val) {
                              user.phone = val;
                            },
                          ),
                        ],
                      ))))
        ],
      );
    }
  }
}
