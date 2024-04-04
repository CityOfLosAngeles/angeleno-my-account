import 'dart:io';

import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth0_user_api_implementation.dart';
import '../../controllers/overlay_provider.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final Auth0UserApi auth0UserApi;

  const ProfileScreen({
    required this.auth0UserApi,
    super.key
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Auth0UserApi auth0UserApi;
  late OverlayProvider overlayProvider;
  late UserProvider userProvider;
  late User user;

  @override
  void initState() {
    super.initState();

    auth0UserApi = widget.auth0UserApi;
  }

  void updateUser() {
    // Only submit patch if data has been updated
    if (!(user == userProvider.cleanUser)) {
      overlayProvider.showLoading();
      auth0UserApi.updateUser(user).then((final response) {
          final success = response == HttpStatus.ok;
          overlayProvider.hideLoading();
          if (success) {
            userProvider.setCleanUser(user);
          }
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
                  Row(mainAxisAlignment: MainAxisAlignment.end,
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
                        userProvider.isEditing ? 'Save' : 'Edit'
                      ),
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
                      labelText: 'Zip', border: OutlineInputBorder()),
                    initialValue: user.zip,
                    onChanged: (final val) {
                      user.zip = val;
                    },
                    keyboardType: TextInputType.number,
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
