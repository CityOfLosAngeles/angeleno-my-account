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
import '../../controllers/Debouncer.dart';
import '../../controllers/api_implementation.dart';
import '../../controllers/overlay_provider.dart';
import '../../models/user.dart';

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

//
  TextEditingController usrAddressTextController = TextEditingController();
  TextEditingController usrCityTextController = TextEditingController();
  TextEditingController usrStateTextController = TextEditingController();
  TextEditingController usrZipTextController = TextEditingController();

  String sessionToken = "";
  //This is needed since the user becomes overwritten to original user data. But if we check the autofill
  bool autoFilled = false;
  final apiFetchDebouncer = Debouncer(milliseconds: 555);
  Timer? timer;
  List<AutofillSuggestion> suggestions = [];

  @override
  void initState() {
    super.initState();
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

  Future<List<AutofillSuggestion>> fetchSuggestions(final String input) async {
    // Implement API call to fetch suggestions based on input
    final PlaceAPI apiClient = PlaceAPI(sessionToken);
    return await apiClient.fetchSuggestions(
        input, Localizations.localeOf(context).languageCode);
    //return results;
  }

  Future<AutofillPlace> getAutofillFullAddress(
      AutofillSuggestion autocomplete) async {
    print('The autocomplete is $autocomplete');

    return await PlaceAPI(sessionToken)
        .getPlaceDetailFromId(autocomplete.placeId!);
  }

  @override
  Widget build(final BuildContext context) {
    overlayProvider = context.watch<OverlayProvider>();
    userProvider = context.watch<UserProvider>();

    if (userProvider.user == null) {
      return const LinearProgressIndicator();
    } else {
      user = userProvider.user!;
    }

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
                        Autocomplete<AutofillSuggestion>(
                          displayStringForOption:
                              (final AutofillSuggestion option) =>
                                  option.description!,
                          fieldViewBuilder: (final BuildContext context,
                              controller,
                              final FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted) {
                            usrAddressTextController = controller;
                            return TextFormField(
                              controller: usrAddressTextController,
                              focusNode: fieldFocusNode,
                              decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder()),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            );
                          },
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '' || autoFilled) {
                              return const Iterable<AutofillSuggestion>.empty();
                            }

                            apiFetchDebouncer.run(() async {
                              final suggs =
                                  await fetchSuggestions(textEditingValue.text);
                              setState(() {
                                // Update suggestions list with retrieved suggestions
                                suggestions = suggs;
                              });
                            });
                            return suggestions; // Prevent initial suggestions before delay
                          },
                          initialValue: TextEditingValue(text: user.address!),
                          onSelected:
                              (final AutofillSuggestion selection) async {
                            print(
                                '\n \n \n \n \n ==========================================================');
                            final place =
                                await getAutofillFullAddress(selection);

                            setState(() {
                              autoFilled = true;
                              user.city = place.city;
                              user.zip = place.zipCode;
                              usrCityTextController.text = place.city!;
                              usrStateTextController.text = place.state!;
                              usrZipTextController.text = place.zipCode!;
                              usrAddressTextController.text =
                                  selection.streetAddress!;
                              //usrAddressTextController.text =
                              //  '${place.streetNumber} ${place.street}';
                            });
//This code is used for re-enabling the autofill as when we substitute the full
//address with the street address it gets triggered again to show suggestion, so it is unnecessary to show it again
                            Future.delayed(const Duration(milliseconds: 1500),
                                () {
                              setState(() {
                                autoFilled = false;
                              });
                            });
                            debugPrint('You just selected $selection');
                          },
                        ),

                        /*
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.streetAddress,
                          initialValue: user.address,
                          onChanged: (final val) {
                            user.address = val;
                          },
                        ),*/
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Address 2',
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
                              labelText: 'City', border: OutlineInputBorder()),
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
                              labelText: 'Zip', border: OutlineInputBorder()),
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
                              labelText: 'State', border: OutlineInputBorder()),
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
