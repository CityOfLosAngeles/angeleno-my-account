// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:angeleno_project/models/password_reset.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/api_implementation.dart';
import '../../controllers/overlay_provider.dart';
import '../../controllers/user_provider.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  late OverlayProvider overlayProvider;
  late UserProvider userProvider;

  late String currentPassword;
  late String newPassword;
  late String passwordMatch;

  late bool viewPassword;
  late bool viewNewPassword;
  late bool viewPasswordMatch;

  late bool _isButtonDisabled;

  late bool acceptableLength;
  late bool hasSpecialCharacter;
  late bool hasUppercaseCharacter;
  late bool hasNumberCharacter;

  late String errorMsg;

  @override
  void initState() {
    super.initState();

    currentPassword = '';
    newPassword = '';
    passwordMatch = '';
    viewPassword = false;
    viewNewPassword = false;
    viewPasswordMatch = false;
    _isButtonDisabled = true;
    acceptableLength = false;
    hasSpecialCharacter = false;
    hasUppercaseCharacter = false;
    hasNumberCharacter = false;
    errorMsg = '';

  }

  void submitRequest() {
    if (newPassword == passwordMatch) {

      setState(() {
        errorMsg = '';
      });

      overlayProvider.showLoading();

      final body = PasswordBody(
        email: userProvider.user!.email,
        oldPassword: currentPassword,
        newPassword: newPassword,
        userId: userProvider.user!.userId
      );

      UserApi().updatePassword(body).then((final response) {
        final success = response['status'] == HttpStatus.ok;
        overlayProvider.hideLoading();
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 280.0,
            content: Text(success ? 'Password updated. Logging out...'
                : 'Password update failed')
        ));

        if (!success) {
          setState(() {
            errorMsg = response['body'].toString();
          });
        } else {
          Future.delayed(const Duration(seconds: 3), () {
            userProvider.logout();
          });
        }
      });

    }
  }

  bool enablePasswordSubmit() => !(currentPassword.trim() != ''
      && newPassword.trim() != '' && passwordMatch.trim() != ''
      && acceptableLength && hasUppercaseCharacter && hasSpecialCharacter
      && hasNumberCharacter);

  @override
  Widget build(final BuildContext context) {
    overlayProvider = context.watch<OverlayProvider>();
    userProvider = context.watch<UserProvider>();

    return userProvider.isThirdParty ?
        Center(
          child: Container(
            transformAlignment: Alignment.center,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1280),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Password is managed by your Google Account.')
              ],
            )
          )
        )
        : ListView(
      children: [
        TextFormField(
          obscureText: !viewPassword,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (final value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Current Password',
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      viewPassword = !viewPassword;
                    });
                  },
                  icon: Icon(
                      viewPassword ? Icons.visibility : Icons.visibility_off
                  )
              )
          ),
          onChanged: (final value) {
            setState(() {
              currentPassword = value;
              _isButtonDisabled = enablePasswordSubmit();
            });
          },
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          obscureText: !viewNewPassword,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (final value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }

            final RegExp passwordRegex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{12,}$',
            );

            if (!passwordRegex.hasMatch(value)) {
              // ignore: avoid_escaping_inner_quotes
              return 'Password doesn\'t meet requirements';
            }

            return null;
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'New Password',
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      viewNewPassword = !viewNewPassword;
                    });
                  },
                  icon: Icon(
                      viewNewPassword ? Icons.visibility : Icons.visibility_off
                  )
              )
          ),
          onChanged: (final value) {
            setState(() {
              newPassword = value;
              _isButtonDisabled = enablePasswordSubmit();
              acceptableLength = value.length >= 12;
              hasNumberCharacter = value.contains(RegExp(r'[0-9]'));
              hasSpecialCharacter =
                  value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
              hasUppercaseCharacter = value.contains(RegExp(r'[A-Z]'));
            });
          },
        ),
        Row(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password must:',
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(
                        'Be at least 12 characters',
                        style: TextStyle(
                            color: acceptableLength
                                ? colorScheme.primary
                                : colorScheme.error
                        )
                    ),
                    Text(
                        'Contain a number character',
                        style: TextStyle(
                            color: hasNumberCharacter
                                ? colorScheme.primary
                                : colorScheme.error
                        )
                    ),

                  ]
              ),
              const SizedBox(width: 10.0),
              Column(
                children: [
                  const Text(''),
                  Text(
                      'Contain a special character',
                      style: TextStyle(
                          color: hasSpecialCharacter
                              ? colorScheme.primary
                              : colorScheme.error
                      )
                  ),
                  Text(
                      'Contain an uppercase letter',
                      style: TextStyle(
                          color: hasUppercaseCharacter
                              ? colorScheme.primary
                              : colorScheme.error
                      )
                  )
                ],
              )
            ],
          ),
        const SizedBox(height: 10.0),
        TextFormField(
          obscureText: !viewPasswordMatch,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (final value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            if (newPassword != value) {
              return "Passwords don't match";
            }
            return null;
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Confirm New Password',
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      viewPasswordMatch = !viewPasswordMatch;
                    });
                  },
                  icon: Icon(
                      viewPasswordMatch ? Icons.visibility : Icons
                          .visibility_off
                  )
              )
          ),
          onChanged: (final value) {
            setState(() {
              passwordMatch = value;
              _isButtonDisabled = enablePasswordSubmit();
            });
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMsg.isNotEmpty)
              Text(errorMsg, style: TextStyle(color: colorScheme.error)),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : () => submitRequest(),
              child: const Text('Update Password and Logout'),
            )
          ],
        ),
      ],
    );
  }
}