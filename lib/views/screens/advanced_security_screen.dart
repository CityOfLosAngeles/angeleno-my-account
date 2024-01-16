// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:convert';

import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:flutter/material.dart';

import '../../controllers/user_provider.dart';
import '../dialogs/authenticator.dart';

class AdvancedSecurityScreen extends StatefulWidget {
  final UserProvider userProvider;

  const AdvancedSecurityScreen({
    required this.userProvider,
    super.key
  });

  @override
  State<AdvancedSecurityScreen> createState() => _AdvancedSecurityState();
}

class _AdvancedSecurityState extends State<AdvancedSecurityScreen> {

  late bool authenticatorEnabled = false;
  late String totpAuthId = '';

  bool initialLoading = true;

  @override
  void initState() {
    super.initState();

    UserApi().getAuthenticationMethods(widget.userProvider.user!.userId)
        .then((final response) {
          final bool success = response.statusCode == HttpStatus.ok;
          if (success) {
            final String jsonString = response.body;
            final List<dynamic> dataList = jsonDecode(jsonString)
              as List<dynamic>;
            if (dataList.isNotEmpty) {
              // When additional MFA is added, we can filter out types
              // then setState once and do typeArray.contains('totp')
              // think more about methods to retrieve auth method id
              for (final element in dataList) {
                if (element['type'] == 'totp') {
                  setState(() {
                    totpAuthId = element['id'] as String;
                    authenticatorEnabled = true;
                    initialLoading = false;
                  });
                }
              }
            } else {
              setState(() {
                initialLoading = false;
              });
            }

          }
    });
  }

  void disableAuthenticator() {
    UserApi().unenrollAuthenticator({
      'authFactorId': totpAuthId,
      'userId': widget.userProvider.user!.userId
    }).then((final response) {
      final bool success = response.statusCode == HttpStatus.ok;
      if (success) {
        Navigator.pop(context, response.statusCode.toString());
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 280.0,
            content: Text('Authenticator app has been removed.')
        ));
        setState(() {
          authenticatorEnabled = false;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context) => initialLoading ?
    const LinearProgressIndicator()
    :
    Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Authenticator App (Timed One-Time Password)'),
            authenticatorEnabled ?
              FilledButton.tonal(
                onPressed: () => showDialog<String>(
                    context: context,
                    builder: (final BuildContext context) => AlertDialog(
                      title: const Text('Remove authenticator app?'),
                      content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              // ignore: avoid_escaping_inner_quotes
                              Text('You won\'t be able to use your authenticator '
                                  'app to sign into your Angeleno Account.')
                            ],
                          )
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, '');
                          },
                        ),
                        TextButton(
                          child: const Text('Ok'),
                          onPressed: () {
                            disableAuthenticator();
                          },
                        )
                      ],
                    )
                ).then((final value) {
                  if (value != null && value == HttpStatus.ok.toString()) {
                    setState(() {
                      authenticatorEnabled = false;
                    });
                  }
                }),
                child: const Text('Disable'),
              )
              :
              FilledButton(
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (final BuildContext context) =>
                      const AuthenticatorDialog(),
                  ).then((final value) {
                    if (value != null && value == HttpStatus.ok.toString()) {
                      setState(() {
                        authenticatorEnabled = true;
                      });
                    }
                  });
                },
                child: Text(authenticatorEnabled ? 'Disable' : 'Enable')
              ),
            ],
        )
      ],
    );
}
