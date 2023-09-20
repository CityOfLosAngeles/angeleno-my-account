import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
//import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/api_implementation.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ProfileScreen3 extends StatefulWidget {
  final UserProfile? user;
  //const ProfileScreen({super.key});
  const ProfileScreen3({required this.user, final Key? key}) : super(key: key);

  @override
  State<ProfileScreen3> createState() => _ProfileScreen3State();
}

class _ProfileScreen3State extends State<ProfileScreen3> {
  late UserProfile? user;
  UserApi userApi = UserApi();
  late User providerUser;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //Credentials creds =  auth0Web.credentials();
    //final isLoggedIn = await auth0Web.hasValidCredentials();
    //user = widget.user!;
    //print('The user from Auth0 is $user');
  }

  void updateUser() {
    print(providerUser.toString());
  }

  @override
  Widget build(final BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    if (userProvider.user == null) {
      userProvider.fetchUser();
      return const LinearProgressIndicator();
    } else {
      providerUser = userProvider.user!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ElevatedButton(
            onPressed: () {
              /*
              if (userProvider.isEditing) {
                updateUser();
              }*/
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
                          initialValue: widget.user!.email,
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: false,
                          decoration: const InputDecoration(
                              labelText: 'Email', border: OutlineInputBorder()),
                          initialValue: providerUser.email,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (final val) {
                            providerUser.email = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder()),
                          initialValue: providerUser.firstName,
                          keyboardType: TextInputType.name,
                          onChanged: (final val) {
                            providerUser.firstName = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder()),
                          initialValue: providerUser.lastName,
                          keyboardType: TextInputType.name,
                          onChanged: (final val) {
                            providerUser.lastName = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Zip', border: OutlineInputBorder()),
                          initialValue: providerUser.zip,
                          onChanged: (final val) {
                            providerUser.zip = val;
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
                          initialValue: providerUser.address,
                          onChanged: (final val) {
                            providerUser.address = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'City', border: OutlineInputBorder()),
                          keyboardType: TextInputType.streetAddress,
                          initialValue: providerUser.city,
                          onChanged: (final val) {
                            providerUser.city = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'State', border: OutlineInputBorder()),
                          keyboardType: TextInputType.streetAddress,
                          onChanged: (final val) {
                            providerUser.state = val;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          enabled: userProvider.isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Mobile',
                              border: OutlineInputBorder()),
                          initialValue: providerUser.phone,
                          onChanged: (final val) {
                            providerUser.phone = val;
                          },
                        ),
                      ],
                    ))))
      ],
    );
  }
}
