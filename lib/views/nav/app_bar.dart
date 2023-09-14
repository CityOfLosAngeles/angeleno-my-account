import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final context) => AppBar(
        backgroundColor: colorGreen,
        title: const Text(
          'Angeleno Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse('https://angeleno.lacity.org/'));
              },
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              label: const Text('Home', style: TextStyle(color: Colors.white)),
              style: angelenoAccountButtonStyle),
          const SizedBox(width: 5.0),
          ElevatedButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse('https://angeleno.lacity.org/apps'));
              },
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
              label:
                  const Text('Services', style: TextStyle(color: Colors.white)),
              style: angelenoAccountButtonStyle),
          const SizedBox(width: 5.0),
          ElevatedButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse('https://angeleno.lacity.org/help'));
              },
              icon: const Icon(
                Icons.question_mark,
                color: Colors.white,
              ),
              label: const Text('Help', style: TextStyle(color: Colors.white)),
              style: angelenoAccountButtonStyle),
          const SizedBox(width: 5.0),
        ],
      );
}
