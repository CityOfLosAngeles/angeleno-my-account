import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final context) => AppBar(
      title: const Text('Angeleno Account',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions:
      <Widget>[
        ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://angeleno.lacity.org/')
              );
            },
            icon: const Icon(Icons.home,),
            label: const Text('Home')),
        const SizedBox(width: 5.0),
        ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://angeleno.lacity.org/apps')
              );
            },
            icon: const Icon(Icons.grid_view_rounded ),
            label: const Text('Services')
        ),
        const SizedBox(width: 5.0),
        ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://angeleno.lacity.org/help')
              );
            },
            icon: const Icon(Icons.question_mark),
            label: const Text('Help')
        ),
        const SizedBox(width: 5.0),
      ],
    );
}