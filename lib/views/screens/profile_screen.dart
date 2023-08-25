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

  /* Proof of Concept for Data Retention on Full Name field */
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final String text = _controller.text;
      _controller.value = _controller.value.copyWith(
          text: text,
          selection: TextSelection(
              baseOffset: text.length,
              extentOffset: text.length
          ),
          composing: TextRange.empty
      );
    });

    user = userApi.getUser('');
    _isEditing = false;
  }

  void updateUser() {
    print(user.toString());
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
                  FormBuilderTextField(
                      name: 'full_name',
                      enabled: false,
                      decoration: const InputDecoration(
                          labelText: 'Full Name'
                      ),
                      controller: _controller,
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'email',
                    enabled: false,
                    decoration: const InputDecoration(
                        labelText: 'Email'
                    ),
                    initialValue: snapshot.data!.email,
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'first_name',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'First Name'
                    ),
                    initialValue: snapshot.data!.name.split(' ')[0],
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'last_name',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Last Name'
                    ),
                    initialValue: snapshot.data!.name.split(' ')[1],
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'zip',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Zip'
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'address',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Address'
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'city',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'City'
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'state',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'State'
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  FormBuilderTextField(
                    name: 'mobile',
                    enabled: _isEditing ? true : false,
                    decoration: const InputDecoration(
                        labelText: 'Mobile'
                    ),
                    initialValue: snapshot.data!.phone,
                    onChanged: (final value) {
                    },
                  ),
                ],
              ),
            );
          }

          return const CircularProgressIndicator();
        }
      )
    );
}