// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool thirdPartyUserSource = false;

  @override
  void initState() {
    super.initState();
  }

  void updateUser() {
    // Only submit patch if data has been updated
    if (!(user == userProvider.cleanUser)) {
       overlayProvider.showLoading();
      UserApi().updateUser(user).then((final response) {
          final success = response == HttpStatus.ok;
          overlayProvider.hideLoading();
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
              behavior: SnackBarBehavior.floating,
              width: 280.0,
              content: Text(success ? 'User updated' : 'User update failed'),
              action: success ? null : SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    updateUser();
                  }
              )
          ));
      });
    }
  }

  ElevatedButton get editButton => ElevatedButton(
    onPressed: thirdPartyUserSource ? null : () {
      if (userProvider.isEditing) {
        updateUser();
      }
      setState(() {
        userProvider.toggleEditing();
      });
    },
    child: Text(
        userProvider.isEditing ? 'Save' : 'Edit'
    ),
  );

  @override
  Widget build(final BuildContext context) {
    overlayProvider = context.watch<OverlayProvider>();
    userProvider = context.watch<UserProvider>();

    if (userProvider.user == null) {
      return const LinearProgressIndicator();
    } else {
      user = userProvider.user!;
      if (user.userId.contains('google-oauth2')) {
        thirdPartyUserSource = true;
      }
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
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            thirdPartyUserSource ?
                            Tooltip(
                              message: 
                                'This data is sourced from Google.',
                              child: editButton,
                          ) : editButton
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
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Zip', border: OutlineInputBorder()),
                          initialValue: user.zip,
                          onChanged: (final val) {
                            user.zip = val;
                          },
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 25.0),
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
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.streetAddress,
                          initialValue: user.city,
                          onChanged: (final val) {
                            user.city = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.streetAddress,
                          initialValue: user.state,
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
                    )
                )
            )
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
