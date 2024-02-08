import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angeleno_project/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Loads initial screen', (final WidgetTester tester) async {

    await tester.pumpWidget(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (final _) => UserProvider()),
              ChangeNotifierProvider(create: (final _) => OverlayProvider())
            ],
            child: const MyApp()
        )
    );

    expect(find.text('Angeleno Account'), findsOneWidget);
  });
}