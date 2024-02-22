import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:angeleno_project/views/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';


void main() {
  setPathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (final _) => UserProvider()),
        ChangeNotifierProvider(create: (final _) => OverlayProvider())
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    title: 'Angeleno - Account',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme
    ),
    onGenerateRoute: (final settings) {
      final uri = Uri.parse(settings.name!);
      
      if (uri.path == '/' && uri.queryParameters.isNotEmpty) {
        return MaterialPageRoute(builder: (final context) => const MyHomePage(),
          settings: const RouteSettings(name: '/'));
      }

      return MaterialPageRoute(builder: (final context) => const MyHomePage(),
        settings: const RouteSettings(name: '/'));
    },
    home: const MyHomePage()
  );
}