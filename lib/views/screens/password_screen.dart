import 'package:angeleno_project/models/password_reset.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/api_implementation.dart';
import '../../controllers/user_provider.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = context.watch<UserProvider>();
  }

  void submitRequest() {
    if (newPassword == passwordMatch) {
      final body = PasswordBody(
        email: userProvider.user!.email,
        oldPassword: currentPassword,
        newPassword: newPassword,
        userId: userProvider.user!.userId
      );

      UserApi().updatePassword(body);

    } else {

    }
  }

  bool enablePasswordSubmit() => !(currentPassword.trim() != ''
      && newPassword.trim() != ''
      && passwordMatch.trim() != '');

  @override
  Widget build(final BuildContext context) => ListView(
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
                      viewPassword ? Icons.visibility  : Icons.visibility_off
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
                      viewNewPassword ? Icons.visibility  : Icons.visibility_off
                  )
              )
          ),
          onChanged: (final value) {
            setState(() {
              newPassword = value;
              _isButtonDisabled = enablePasswordSubmit();
              acceptableLength = value.length >= 12;
              hasNumberCharacter = value.contains(RegExp(r'[0-9]'));
              hasSpecialCharacter = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
              hasUppercaseCharacter = value.contains(RegExp(r'[A-Z]'));
            });
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Password must:'),
            Text(
              '  - Be greater than 8 characters',
              style: TextStyle(
                color: acceptableLength ? colorScheme.primary : colorScheme.error
              )
            ),
            Text(
                '  - Contain a number character',
                style: TextStyle(
                    color: hasNumberCharacter ? colorScheme.primary : colorScheme.error
                )
            ),
            Text(
                '  - Contain a special character',
                style: TextStyle(
                    color: hasSpecialCharacter ? colorScheme.primary : colorScheme.error
                )
            ),
            Text(
                '  - Contain an uppercase letter',
                style: TextStyle(
                    color: hasUppercaseCharacter ? colorScheme.primary : colorScheme.error
                )
            )
          ]
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
                    viewPasswordMatch ? Icons.visibility : Icons.visibility_off
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
        const SizedBox(height: 10.0),
        Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : () => submitRequest(),
              child: const Text('Update Password and Logout'),
            )
          ],
        ),
      ],
    );

}