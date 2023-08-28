import 'package:flutter/material.dart';

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
    disabledBackgroundColor: Colors.transparent,
    alignment: Alignment.center,
    textStyle: const TextStyle(
        color: Colors.black
    ),
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.white,
    shadowColor: Colors.transparent,
    // shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
    //     side: BorderSide()
    // )
);