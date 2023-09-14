import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/api_implementation.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ProfileScreenAuth0 extends StatefulWidget {
  final UserProfile? user;
  //const ProfileScreen({super.key});
  const ProfileScreenAuth0({required this.user, final Key? key})
      : super(key: key);

  @override
  State<ProfileScreenAuth0> createState() => _ProfileScreenAuth0();
}

class _ProfileScreenAuth0 extends State<ProfileScreenAuth0> {
  late UserProfile? user;
  UserApi userApi = UserApi();
  late User providerUser;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    print('The user from Auth0 is $user');
  }

  @override
  Widget build(BuildContext context) {
    final pictureUrl = user?.pictureUrl;
    // id, name, email, email verified, updated_at
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (pictureUrl != null)
        Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CircleAvatar(
              radius: 56,
              child: ClipOval(child: Image.network(pictureUrl.toString())),
            )),
      Card(
          child: Column(children: [
        UserEntryWidget(propertyName: 'Id', propertyValue: user?.sub),
        UserEntryWidget(propertyName: 'Name', propertyValue: user?.name),
        UserEntryWidget(propertyName: 'Email', propertyValue: user?.email),
        UserEntryWidget(
            propertyName: 'Email Verified?',
            propertyValue: user?.isEmailVerified.toString()),
        UserEntryWidget(
            propertyName: 'Updated at',
            propertyValue: user?.updatedAt?.toIso8601String()),
      ]))
    ]);
  }
}

class UserEntryWidget extends StatelessWidget {
  final String propertyName;
  final String? propertyValue;

  const UserEntryWidget(
      {required this.propertyName, required this.propertyValue, final Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(propertyName), Text(propertyValue ?? '')],
        ));
  }

/*
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
                          initialValue: providerUser.fullName,
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
  }*/
}
