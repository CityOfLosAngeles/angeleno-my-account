import 'dart:html';

import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/user_provider.dart';

class AdvancedSecurityScreen extends StatefulWidget {
  const AdvancedSecurityScreen({super.key});

  @override
  State<AdvancedSecurityScreen> createState() => _AdvancedSecurityState();
}

class _AdvancedSecurityState extends State<AdvancedSecurityScreen> {

  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final passwordField = TextEditingController();
  late UserProvider userProvider;
  String otpQrCode = '';
  String qrCodeAltString = '';
  String mfaToken = '';
  String otpCode = '';
  String userPassword = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordField.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void enrollOTP() async {

    if (passwordField.text.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'email': userProvider.user!.email,
      'password': passwordField.text
    };

    UserApi().enrollOTP(body).then((final response) {
      final bool success = response['status'] == HttpStatus.ok;
      if (success) {
        setState(() {
          otpQrCode = response['barcode'] as String;
          mfaToken = response['token'] as String;
          qrCodeAltString = response['barcode_string'] as String;
          _pageIndex++;
        });
        _navigateToNextPage();
      }
    });
  }

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
                    data: otpQrCode,
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
                final Map<String, String> body = {
                  'mfaToken': mfaToken,
                  'userOtpCode': otpCode
                };
                UserApi().confirmOTP(body).then((final response) {
                  if (response['status'] == HttpStatus.ok) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      width: 280.0,
                      content: Text('Authenticator app has been set up.')
                    ));
                  }
                });
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
                        child: TextField(
                          onChanged: (final val) {
                            setState(() {
                              otpCode = val;
                            });
                          },
                        )
                    )
                  ],
                )
            )
        )
      ]
  );

  List<Widget> get screens => [
    Column(
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
                enrollOTP();
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
                  ' in to your account. \n Please enter your password:',
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 250,
                  child: TextFormField(
                    controller: passwordField,
                    onFieldSubmitted: (final value) {
                      enrollOTP();
                    },
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (final value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
    qrCodeScreen,
    confirmationScreen
  ];

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

  @override
  Widget build(final BuildContext context) {
    userProvider = context.watch<UserProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Authenticator App (Timed One-Time Password)'),
        FilledButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (final BuildContext context) => Dialog(
              insetPadding: EdgeInsets.zero,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  // itemCount: 3,
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
            )
          ),
          child: const Text('Enable')
        ),
      ],
    );
  }
}

