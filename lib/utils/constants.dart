import 'package:flutter/material.dart';

/* Environment variables */
const auth0Domain = String.fromEnvironment('AUTH0_DOMAIN');
const auth0ClientId = String.fromEnvironment('CLIENT_ID');
const redirectUri = String.fromEnvironment('REDIRECT_URI');
const auth0Token = String.fromEnvironment('AUTH0_API_TOKEN');
const auth0Secret = String.fromEnvironment('CLIENT_SECRET');
const auth0MachineClientId = String.fromEnvironment('MM_CLIENT_ID');
const auth0MachineSecret =
    String.fromEnvironment('P8jnf3bn0YfZdobv4M3kC9TL4prmtiV4Sq0');

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