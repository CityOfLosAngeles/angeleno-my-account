import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../controllers/api_implementation.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserApi userApi = UserApi();
  late Future<User> user;
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  late bool _isEditing;

  @override
  void initState() {
    super.initState();

    user = userApi.getUser('');
    _isEditing = false;
  }

  void updateUser() {
    // Send request
    // print to debug
    user.then((final value) => print(value.toString()));
  }

  @override
  Widget build(final BuildContext context) => FormBuilder(
      key: formKey,
      onChanged: () {
        formKey.currentState!.save();
      },
      autovalidateMode: AutovalidateMode.disabled,
      skipDisabled: true,
      child: FutureBuilder<User>(
        future: user,
        builder: (final context, final snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_isEditing) {
                              updateUser();
                            }
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                          style: actionButtonStyle,
                          child: Text(_isEditing ? 'Save' : 'Edit'),
                        )
                      ]
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder()
                      ),
                      keyboardType: TextInputType.name,
                      initialValue: snapshot.data!.fullName,
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: false,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder()
                    ),
                    initialValue: snapshot.data!.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (final val) {
                      snapshot.data!.email = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder()
                    ),
                    initialValue: snapshot.data!.firstName,
                    keyboardType: TextInputType.name,
                    onChanged: (final val) {
                      snapshot.data!.firstName = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder()
                    ),
                    initialValue: snapshot.data!.lastName,
                    keyboardType: TextInputType.name,
                    onChanged: (final val) {
                      snapshot.data!.lastName = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Zip',
                        border: OutlineInputBorder()
                    ),
                    initialValue: snapshot.data!.zip,
                    onChanged: (final val) {
                      snapshot.data!.zip = val;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.streetAddress,
                    onChanged: (final val) {
                      snapshot.data!.address = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.streetAddress,
                    onChanged: (final val) {
                      snapshot.data!.city = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.streetAddress,
                    onChanged: (final val) {
                      snapshot.data!.state = val;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Mobile',
                        border: OutlineInputBorder()
                    ),
                    initialValue: snapshot.data!.phone,
                    onChanged: (final val) {
                      snapshot.data!.phone = val;
                    },
                  ),
                ],
              ),
            );
          }

          return const LinearProgressIndicator();
        }
      )
    );
}