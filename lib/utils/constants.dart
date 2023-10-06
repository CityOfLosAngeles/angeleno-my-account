import 'package:flutter/material.dart';

/* Environment variables */
const auth0ClientId = String.fromEnvironment('CLIENT_ID');
const auth0Domain = String.fromEnvironment('AUTH0_DOMAIN');
const redirectUri = String.fromEnvironment('REDIRECT_URI');
const cloudFunctionURL =
    String.fromEnvironment('CLOUD_FUNCTIONS_URL');
const serviceAccountSecret = String.fromEnvironment('SA_SECRET_KEY');
const serviceAccountEmail = String.fromEnvironment('SA_EMAIL');

/* Colors */
const footerBlue = Color(0xFF1f4c73);
const colorBlue = Color(0xFF0f2940);
const colorGreen = Color(0xFF03a751);

/* Button Styles */
final angelenoAccountButtonStyle =  ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
    overlayColor: MaterialStateProperty.all<Color>(const Color(0xff0daa58)),
    alignment: Alignment.center,
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder()
    )
);

final actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: colorGreen,
    disabledBackgroundColor: const Color(0xFF81d3a8),
    disabledForegroundColor: Colors.white,
    alignment: Alignment.center,
    textStyle: const TextStyle(
        color: Colors.white
    ),
    foregroundColor: Colors.white,
);