import 'package:angeleno_project/models/password_reset.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = context.watch<UserProvider>();
  }

  String? validatePasswords (final String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : () => submitRequest(),
              child: const Text('Change Password'),
            )
          ],
        ),
        const SizedBox(height: 30.0),
        TextFormField(
          obscureText: !viewPassword,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatePasswords,
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
          validator: validatePasswords,
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
            });
          },
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
      ],
    );

}