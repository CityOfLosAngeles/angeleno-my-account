import 'dart:io';
import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../controllers/user_provider.dart';
import '../../utils/constants.dart';

class MobileDialog extends StatefulWidget {
  final UserProvider userProvider;
  final String channel;

  const MobileDialog({
    required this.userProvider,
    required this.channel,
    super.key
  });

  @override
  State<MobileDialog> createState() => _MobileDialogState();
}

class _MobileDialogState extends State<MobileDialog> {

  final PageController _pageController = PageController();
  final passwordField = TextEditingController();
  final phoneField = TextEditingController();

  late UserProvider userProvider;
  late String channel;

  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String initialCountry = 'US';

  String errMsg = '';
  String phoneNumber = '';
  String userPassword = '';
  String mfaToken = '';
  String oobCode = '';
  String codeProvided = '';
  bool obscurePassword = true;
  bool validPhoneNumber = false;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();

    userProvider = widget.userProvider;
    channel = widget.channel;
  }

  @override
  void dispose() {
    passwordField.dispose();
    phoneField.dispose();
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

  void enrollMobile() async {
    setState(() {
      errMsg = '';
    });

    if (passwordField.text.isEmpty || !validPhoneNumber) {
      return;
    }

    final Map<String, String> body = {
      'email': userProvider.user!.email,
      'password': passwordField.text,
      'mfaFactor': 'oob',
      'channel': channel,
      'number': phoneNumber
    };

    UserApi().enrollMFA(body).then((final response) {
      final bool success = response['status'] == HttpStatus.ok;
      if (success) {
        oobCode = response['oobCode'] as String;
        mfaToken = response['token'] as String;
        _navigateToNextPage();
      }
    });
  }

  void confirmCode() async {
    setState(() {
      errMsg = '';
    });

    if (codeProvided.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'mfaToken': mfaToken,
      'oobCode': oobCode,
      'userOtpCode': codeProvided
    };

    UserApi().confirmMFA(body).then((final response) {
      if (response.statusCode == HttpStatus.ok) {
        Navigator.pop(context, response.statusCode.toString());
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 280.0,
          content: Text('$channel MFA has been enabled.')
        ));
      }
    });
  }

  Widget get dialogClose => IconButton(
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          _pageIndex = 0;
        });
      },
      icon: const Icon(Icons.close)
  );

  Widget get phonePrompt => Column(
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
              const Text(
                'Please enter your phone number:',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 500,
                child: InternationalPhoneNumberInput(
                  onInputChanged: (final PhoneNumber number) {
                    phoneNumber = number.phoneNumber!;
                  },
                  onInputValidated: (final bool value) {
                   validPhoneNumber = value;
                  },
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: phoneField,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true
                  ),
                  inputBorder: const OutlineInputBorder(),
                  onSaved: (final PhoneNumber number) {
                    print('On Saved: $number');
                  },
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );

  Widget get passwordPrompt => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dialogClose,
          TextButton(
            onPressed: () {
              enrollMobile();
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
              const SizedBox(height: 15),
              const Text(
                'Please enter your password:',
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

  Widget get codeScreen => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dialogClose,
          TextButton(
            onPressed: () {
              confirmCode();
            },
            child: const Text('Continue')
          )
        ],
      ),
      Expanded(
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please enter the code received:'),
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
                      codeProvided = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),
              if (errMsg.isNotEmpty)
                Text(errMsg, style: TextStyle(color: colorScheme.error))
            ],
          ),
        )
      )
    ],
  );

  List<Widget> get screens => [
    phonePrompt,
    passwordPrompt,
    codeScreen
  ];

  @override
  Widget build(final BuildContext context) => Dialog(
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
          child: screens[_pageIndex],
        )
      ),
    ),
  );
}