import 'dart:io';
import 'package:angeleno_project/controllers/auth0_user_api_implementation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../controllers/user_provider.dart';
import '../../utils/constants.dart';

class MobileDialog extends StatefulWidget {
  final UserProvider userProvider;
  final Auth0UserApi userApi;
  final String channel;

  const MobileDialog({
    required this.userProvider,
    required this.userApi,
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
  late Auth0UserApi api;
  late String channel;

  final isNotTestMode = kIsWeb ||
      !Platform.environment.containsKey('FLUTTER_TEST');

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
    api = widget.userApi;
    channel = widget.channel;
  }

  @override
  void dispose() {
    passwordField.dispose();
    phoneField.dispose();
    super.dispose();
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

    if (passwordField.text.isEmpty) {
      return;
    }

    final Map<String, String> body = {
      'email': userProvider.user!.email,
      'password': passwordField.text,
      'mfaFactor': 'oob',
      'channel': channel,
      'number': phoneNumber
    };

    api.enrollMFA(body).then((final response) {
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

    api.confirmMFA(body).then((final response) {
      if (response.statusCode == HttpStatus.ok) {
        Navigator.pop(context, response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 280.0,
          content: Text('$channel MFA has been enabled.')
        ));
      }
    });
  }

  Widget get phonePrompt => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dialogClose,
          TextButton(
            onPressed: () {
              try {
                if (!validPhoneNumber && isNotTestMode) {
                  return;
                }
                _navigateToNextPage();
              } catch (e) {}
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
                  autoFocus: isNotTestMode,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET
                  ),
                  key: const Key('phoneField'),
                  onInputChanged: (final PhoneNumber number) {
                    phoneNumber = number.phoneNumber!;
                  },
                  onInputValidated: (final bool value) {
                   validPhoneNumber = value;
                  },
                  autoValidateMode: isNotTestMode ?
                    AutovalidateMode.always : AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: phoneField,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true
                  ),
                  inputBorder: const OutlineInputBorder()
                ),
              )
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
                key: const Key('passwordField'),
                width: 250,
                child: TextFormField(
                  autofocus: true,
                  controller: passwordField,
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
                        key: const Key('toggle_password'),
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
                  key: const Key('phoneCode'),
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

  Widget get dialogBody => SizedBox(
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