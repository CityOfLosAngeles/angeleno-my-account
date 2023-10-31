import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/api_implementation.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProvider userProvider;
  late User user;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = context.watch<UserProvider>();
  }

  void updateUser() {
    // Only submit patch if data has been updated
    if (!(user == userProvider.cleanUser)) {
      UserApi().updateUser(user);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    if (userProvider.user == null) {
      return const LinearProgressIndicator();
    } else {
      user = userProvider.user!;
      _controller.value = _controller.value.copyWith(
          text: '${user.firstName} ${user.lastName}'
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ElevatedButton(
            onPressed: () {
              if (userProvider.isEditing) {
                updateUser();
              }
              setState(() {
                userProvider.toggleEditing();
              });
            },
            style: actionButtonStyle,
            child: Text(userProvider.isEditing ? 'Save' : 'Edit'),
          )
        ]),
        const SizedBox(height: 20.0),
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
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.name,
                            controller: _controller,
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder()),
                            initialValue: user.email,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (final val) {
                              user.email = val;
                            },
                          ),
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
                              _controller.value = _controller.value.copyWith(
                                text: '$val ${user.lastName}'
                              );
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
                              _controller.value = _controller.value.copyWith(
                                  text: '${user.firstName} $val'
                              );
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
    _controller.dispose();
    super.dispose();
  }
}
