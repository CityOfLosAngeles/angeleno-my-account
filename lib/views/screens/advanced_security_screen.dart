import 'dart:io';
import 'dart:convert';

import 'package:angeleno_project/controllers/auth0_user_api_implementation.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:angeleno_project/views/dialogs/mobile.dart';
import 'package:flutter/material.dart';


import '../../controllers/user_provider.dart';
import '../dialogs/authenticator.dart';

class AdvancedSecurityScreen extends StatefulWidget {
  final UserProvider userProvider;
  final Auth0UserApi auth0UserApi;

  const AdvancedSecurityScreen({
    required this.userProvider,
    required this.auth0UserApi,
    super.key
  });

  @override
  State<AdvancedSecurityScreen> createState() => _AdvancedSecurityState();
}

class _AdvancedSecurityState extends State<AdvancedSecurityScreen> {

  late Auth0UserApi auth0UserApi;
  late UserProvider userProvider;

  late bool authenticatorEnabled = false;
  late bool smsEnabled = false;
  late bool voiceEnabled = false;

  late String totpAuthId = '';
  late String smsAuthId = '';
  late String voiceAuthId = '';

  late Future<void> _authMethods;

  @override
  void initState() {
    super.initState();
    userProvider = widget.userProvider;
    auth0UserApi = widget.auth0UserApi;
    _authMethods = getAuthenticationMethods();
  }

  Future<void> getAuthenticationMethods() async {
    await auth0UserApi.getAuthenticationMethods(userProvider.user!.userId)
      .then((final response) {
        final bool success = response.statusCode == HttpStatus.ok;
        if (success) {
          final String jsonString = response.body;
          final List<dynamic> dataList = jsonDecode(jsonString)
            as List<dynamic>;
          if (dataList.isNotEmpty) {
            for (final element in dataList) {
              final type = element['type'] as String;
              final methodId = element['id'] as String;

              switch(type) {
                case 'totp':
                  authenticatorEnabled = true;
                  totpAuthId = methodId;
                  break;
                case 'phone':
                  final prefMethod =
                    element['preferred_authentication_method'] as String;
                  if (prefMethod == 'sms') {
                    smsEnabled = true;
                    smsAuthId = methodId;
                  } else {
                    voiceEnabled = true;
                    voiceAuthId = methodId;
                  }
              }
            }
          }
        }
    });
  }

  void disableMFA(final String mfaAuthId, final String method) {
    auth0UserApi.unenrollMFA({
      'authFactorId': mfaAuthId,
      'userId': widget.userProvider.user!.userId
    }).then((final response) {
      final bool success = response.statusCode == HttpStatus.ok;
      if (success) {
        Navigator.pop(context, response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 280.0,
          content: Text('Authenticator app has been removed.')
        ));
        setState(() {
          switch(method) {
            case 'totp':
              authenticatorEnabled = false;
              break;
            case 'sms':
              smsEnabled = false;
              break;
          }
        });
      }
    });
  }

  List<Map<String, dynamic>> get connectedServices => [
    {
      'name': 'Connected Application I',
      'icon': 'https://i.insider.com/60817ec5354dde0018c06960',
      'scopes': ['openid', 'profile', 'email'],
    },
    {
      'name': 'Connected Application II',
      'icon': 'https://media.tenor.com/V1S0oPlXmeQAAAAM/chick-fil-a-no-chick-fil-a-sauce.gif',
      'scopes': ['openid', 'profile', 'email'],
    },
    {
      'name': 'Connected Application III',
      'icon': 'https://play-lh.googleusercontent.com/E-zhAf4KJ6JDDXmQfQxBprn2sATGYUMkOEqLQX5HAQQtiwDZJg4c8sQd7deb6nCZCwU',
      'scopes': ['openid', 'profile', 'email'],
    },
  ];

  @override
  Widget build(final BuildContext context) => FutureBuilder(
    future: _authMethods, 
    builder:(final BuildContext context, final AsyncSnapshot<void> snapshot) =>
      snapshot.connectionState == ConnectionState.done ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Multi-Factor Authentication',
                textAlign: TextAlign.left,
                style: headerStyle
              )
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                  'Authenticator App (Timed One-Time Password)',
                    softWrap: true,
                  ),
                ),
                authenticatorEnabled ?
                  FilledButton.tonal(
                    key: const Key('disableAuthenticator'),
                    onPressed: () => showDialog<int>(
                      context: context,
                      builder: (final BuildContext context) => AlertDialog(
                        title: const Text('Remove authenticator app?'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              // ignore: avoid_escaping_inner_quotes
                              Text('You won\'t be able to use your  '
                                'authenticator app to sign into your Angeleno '
                                 'Account.')
                            ],
                          )
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () {
                              disableMFA(totpAuthId, 'totp');
                            },
                          )
                        ],
                      )
                    ).then((final value) {
                      if (value != null && value == HttpStatus.ok) {
                        setState(() {
                          authenticatorEnabled = false;
                        });
                      }
                    }),
                    child: const Text('Disable'),
                  )
                  :
                  FilledButton(
                    key: const Key('enableAuthenticator'),
                    onPressed: () {
                      showDialog<int>(
                        context: context,
                        builder: (final BuildContext context) =>
                          AuthenticatorDialog(
                            userProvider: userProvider,
                            auth0UserApi: auth0UserApi
                          ),
                      ).then((final value) {
                        if (value != null && value == HttpStatus.ok){
                          setState(() {
                            authenticatorEnabled = true;
                          });
                        }
                      });
                    },
                    child: const Text('Enable')
                  ),
                ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SMS Text'),
                smsEnabled ?
                FilledButton.tonal(
                  key: const Key('disableSMS'),
                  onPressed: () => showDialog<int>(
                      context: context,
                      builder: (final BuildContext context) => AlertDialog(
                        title: const Text('Remove SMS MFA?'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              // ignore: avoid_escaping_inner_quotes
                              Text('Do you confirm to remove SMS Text? This'
                              ' action is irreversible. If you want to use this'
                              ' factor again you will need to enroll the'
                              ' factor again.')
                            ],
                          )
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () {
                              disableMFA(smsAuthId, 'sms');
                            },
                          )
                        ],
                      )
                  ).then((final value) {
                    if (value != null && value == HttpStatus.ok) {
                      setState(() {
                        smsEnabled = false;
                      });
                    }
                  }),
                  child: const Text('Disable'),
                )
                :
                FilledButton(
                    key: const Key('enableSMS'),
                    onPressed: () {
                    showDialog<int>(
                      context: context,
                      builder: (
                        final BuildContext context) => MobileDialog(
                        userProvider: userProvider,
                        userApi: auth0UserApi,
                        channel: 'sms',
                      )
                    ).then((final value) {
                      if (value != null && value == HttpStatus.ok) {
                        setState(() {
                          smsEnabled = true;
                        });
                      }
                    });
                  },
                  child: const Text('Enable')
                )
              ]
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phone Call'),
                voiceEnabled ?
                FilledButton.tonal(
                  key: const Key('disableVoice'),
                  onPressed: () => {},
                  child: const Text('Disable'),
                )
                :
                FilledButton(
                  key: const Key('enableVoice'),
                  onPressed: () {
                    showDialog<int>(
                      context: context,
                      builder: (
                        final BuildContext context) => MobileDialog(
                        userProvider: userProvider,
                        userApi: auth0UserApi,
                        channel: 'voice',
                      )
                    ).then((final value) {
                      if (value != null && value == HttpStatus.ok) {
                        setState(() {
                          voiceEnabled = true;
                        });
                      }
                    });
                  },
                  child: const Text('Enable')
                )
              ]
            ),
            const SizedBox(height: 25),
            Semantics(
                header: true,
                child: const Text(
                  'Your Connected Services',
                  textAlign: TextAlign.left,
                  style: headerStyle
                )
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: connectedServices.length,
              itemBuilder: (final BuildContext context, final int index) {
                final service = connectedServices[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      semanticLabel: '${service['name'] as String} logo',
                      service['icon'] as String,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Text(service['name'] as String),
                  subtitle: Text(service['scopes'].join(', ').toString()),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Disconnect')
                  ),
                );
              }
            )
          ],
        )
        :
        const LinearProgressIndicator()
  );
}
