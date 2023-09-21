import 'package:flutter/material.dart';

/* Colors */

ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xff676000),
    onPrimary: Color(0xffffffff),
    primaryContainer: Color(0xffefe581),
    onPrimaryContainer: Color(0xff1f1c00),
    secondary: Color(0xff635f41),
    onSecondary: Color(0xffffffff),
    secondaryContainer: Color(0xffe9e3be),
    onSecondaryContainer: Color(0xff1e1c05),
    tertiary: Color(0xff3f6653),
    onTertiary: Color(0xffffffff),
    tertiaryContainer: Color(0xffc1ecd4),
    onTertiaryContainer: Color(0xff002114),
    error: Color(0xffba1a1a),
    onError: Color(0xffffffff),
    errorContainer: Color(0xffffdad6),
    onErrorContainer: Color(0xff410002),
    background: Color(0xfffffbff),
    onBackground: Color(0xff1b1b1f),
    surface: Color(0xfffffbff),
    onSurface: Color(0xff1b1b1f),
    surfaceVariant: Color(0xffe7e3d0),
    onSurfaceVariant: Color(0xff49473a),
    outline: Color(0xff7a7768),
    shadow: Color(0xff000000),
    inverseSurface: Color(0xff32302b),
    onInverseSurface: Color(0xfff5f0e7),
    inversePrimary: Color(0xffd4ca51),
    brightness: Brightness.light
);

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