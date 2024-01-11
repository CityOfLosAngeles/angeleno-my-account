// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:convert';

import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/user_provider.dart';
import '../../utils/constants.dart';

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
              TextButton(
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
                child: const Text('Disabled'),
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

class AuthenticatorDialog extends StatefulWidget {
  const AuthenticatorDialog({super.key});

  @override
  State<AuthenticatorDialog> createState() => _AuthenticatorDialogState();
}

class _AuthenticatorDialogState extends State<AuthenticatorDialog> {

  final PageController _pageController = PageController();
  final passwordField = TextEditingController();

  late UserProvider userProvider;

  int _pageIndex = 0;
  String errMsg = '';
  String totpQrCode = '';
  String totpCode = '';
  String qrCodeAltString = '';
  String mfaToken = '';

  String userPassword = '';
  bool obscurePassword = true;

  @override
  void dispose() {
    passwordField.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNextPage() {
    if (_pageIndex <= 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
    } else {
      Navigator.pop(context);
    }
  }

  void enrollTOTP() async {

    setState(() {
      errMsg = '';
    });

    if (passwordField.text.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'email': userProvider.user!.email,
      'password': passwordField.text
    };

    UserApi().enrollAuthenticator(body).then((final response) {
      final bool success = response['status'] == HttpStatus.ok;
      if (success) {
        setState(() {
          totpQrCode = response['barcode'] as String;
          mfaToken = response['token'] as String;
          qrCodeAltString = response['barcode_string'] as String;
        });
        _navigateToNextPage();
      } else {
        setState(() {
          errMsg = response['body'] as String;
        });
      }
    });
  }

  void confirmTOTP() async {

    setState(() {
      errMsg = '';
    });

    if (totpCode.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'mfaToken': mfaToken,
      'userOtpCode': totpCode
    };
    UserApi().confirmTOTP(body).then((final response) {
      if (response.statusCode == HttpStatus.ok) {
        Navigator.pop(context, response.statusCode.toString());
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 280.0,
            content: Text('Authenticator app has been set up.')
        ));
      } else {
        setState(() {
          errMsg = response.body;
        });
      }
    });
  }

  Widget get passwordPrompt => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pageIndex = 0;
              });
            },
            icon: const Icon(Icons.close),
          ),
          TextButton(
            onPressed: () {
              enrollTOTP();
            },
            child: const Text('Continue'),
          )
        ],
      ),
      Expanded(
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
              'Set up Multi-Factor Authentication (MFA). Continue MFA '
                  'setup to add an additional layer of security when signing '
                  'in to your account. \n Please enter your password:',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 250,
                child: TextFormField(
                  autofocus: true,
                  controller: passwordField,
                  onFieldSubmitted: (final value) {
                    enrollTOTP();
                  },
                  obscureText: obscurePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (final value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off
                      ),
                    )
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (errMsg.isNotEmpty)
                Text(errMsg, style: TextStyle(color: colorScheme.error))
            ],
          ),
        ),
      )
    ],
  );

  Widget get qrCodeScreen =>  Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _pageIndex = 0;
                });
              },
              icon: const Icon(Icons.close),
            ),
            TextButton(
              onPressed: () {
                _navigateToNextPage();
              },
              child: const Text('Continue'),
            )
          ],
        ),
        Expanded(
          child: Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Setup Authenticator. Scan code below:',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal
                  ),
                ),
                QrImageView(
                  data: totpQrCode,
                  size: 150
                ),
                Text(
                  qrCodeAltString,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal
                  )
                )
              ],
            ),
          ),
        )
      ]
  );

  Widget get confirmationScreen => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _pageIndex = 0;
                });
              },
              icon: const Icon(Icons.close),
            ),
            TextButton(
              onPressed: () {
               confirmTOTP();
              },
              child: const Text('Finish'),
            )
          ],
        ),
        Expanded(
          child: Align(
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter code displayed from the application:',
                  textAlign: TextAlign.center,
                  softWrap: true
                ),
                SizedBox(
                  width: 250,
                  child: TextFormField(
                    autofocus: true,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (final value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Code is required';
                      }
                      return null;
                    },
                    onChanged: (final val) {
                      setState(() {
                        totpCode = val;
                      });
                    },
                  )
                ),
                const SizedBox(height: 15),
                if (errMsg.isNotEmpty)
                  Text(errMsg, style: TextStyle(color: colorScheme.error))
              ],
            )
          )
        )
      ]
  );

  List<Widget> get screens => [
    passwordPrompt,
    qrCodeScreen,
    confirmationScreen
  ];

  @override
  Widget build(final BuildContext context) {

    userProvider = context.watch<UserProvider>();

    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: PageView.builder(
          controller: _pageController,
          itemCount: 3,
          onPageChanged: (final index) {
            setState(() {
              _pageIndex++;
            });
          },
          itemBuilder: (final context, final index) => Container(
            padding: const EdgeInsets.all(20),
            child: screens[_pageIndex]
          )
        ),
      )
    );
  }
}