import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/auth0_user_api_implementation.dart';
import '../../controllers/user_provider.dart';
import '../../utils/constants.dart';

class AuthenticatorDialog extends StatefulWidget {
  final UserProvider userProvider;
  final Auth0UserApi auth0UserApi;

  const AuthenticatorDialog({
    required this.userProvider,
    required this.auth0UserApi,
    super.key
  });

  @override
  State<AuthenticatorDialog> createState() => _AuthenticatorDialogState();
}

class _AuthenticatorDialogState extends State<AuthenticatorDialog> {

  final PageController _pageController = PageController();
  final passwordField = TextEditingController();

  late UserProvider userProvider;
  late Auth0UserApi auth0UserApi;

  int _pageIndex = 0;
  String errMsg = '';
  String totpQrCode = '';
  String totpCode = '';
  String qrCodeAltString = '';
  String mfaToken = '';

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    userProvider = widget.userProvider;
    auth0UserApi = widget.auth0UserApi;

    passwordField.addListener(() {
      setState(() {});
    });
  }

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

  Widget get dialogClose => IconButton(
    onPressed: () {
      if (_pageIndex >= 1) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut
        );
      } else {
        Navigator.pop(context);
      }
    },
    icon: Icon(_pageIndex == 0 ? Icons.close : Icons.arrow_back)
  );

  void enrollTOTP() async {

    setState(() {
      errMsg = '';
    });

    if (passwordField.text.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'email': userProvider.user!.email,
      'password': passwordField.text,
      'mfaFactor': 'otp'
    };

    auth0UserApi.enrollMFA(body).then((final response) {
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

    auth0UserApi.confirmMFA(body).then((final response) {
      if (response.statusCode == HttpStatus.ok) {
        Navigator.pop(context, response.statusCode);
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
          dialogClose,
          TextButton(
            onPressed: passwordField.text.isEmpty ? null : () {
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
                key: const Key('passwordField'),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (final value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        key: const Key('toggle_password'),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          // ignore: lines_longer_than_80_chars
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
            dialogClose,
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
                const SizedBox(height: 20),
                const Text('If unable to scan, please enter the code below:'),
                const SizedBox(height: 15),
                SelectableText(
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
          dialogClose,
          TextButton(
            onPressed: totpCode.isEmpty ? null : () {
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
                      key: const Key('totpCode'),
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget get dialogBody => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: PageView.builder(
      controller: _pageController,
      itemCount: 3,
      onPageChanged: (final index) {
        setState(() {
          _pageIndex = index;
        });
      },
      itemBuilder: (final context, final index) => Container(
          padding: const EdgeInsets.all(20),
          child: screens[_pageIndex]
      )
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < smallScreen;

    return isSmallScreen ?
      Dialog.fullscreen(
        child: dialogBody
      )
      :
      Dialog(
        child: dialogBody
      );
  }
}