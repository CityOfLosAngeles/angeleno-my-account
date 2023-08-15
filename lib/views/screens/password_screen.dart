import 'package:angeleno_project/models/constants.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {

  var constants = Constants();

  static bool viewPassword = false;
  static bool viewNewPassword = false;
  static bool viewPasswordMatch = false;

  late String currentPassword;
  late String newPassword;
  late String passwordMatch;
  late bool _isButtonDisabled;

  @override
  void initState() {
    super.initState();

    currentPassword = '';
    newPassword = '';
    passwordMatch = '';
    _isButtonDisabled = true;
  }

  String? validatePasswords (final String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void submitRequest() {
    if (newPassword == passwordMatch) {
      //submit request to finalize updated
    }
  }

  bool enablePasswordSubmit() => !(currentPassword.trim() != ''
      && newPassword.trim() != ''
      && passwordMatch.trim() != '');

  @override
  Widget build(final BuildContext context) => ListView(
      children: [
        const SizedBox(height: 5.0),
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
          validator: validatePasswords,
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
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : () => submitRequest(),
              style: constants.actionButtonStyle,
              child: const Text('Change Password'),
            )
          ],
        )

      ],
    );

}