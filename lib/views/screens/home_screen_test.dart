import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchMock extends Mock {
  Future<bool> call(
    final Uri url, {
    final LaunchMode? mode,
    final WebViewConfiguration? webViewConfiguration,
    final String? webOnlyWindowName,
  });
}

void main() {
  testWidgets('Test launching URL', (final WidgetTester tester) async {
    final mock = LaunchMock();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RaisedButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse('https://angeleno.lacity.org/'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RaisedButton));
    verify(() => mock.call(
      Uri.parse('https://angeleno.lacity.org/'),
      mode: anyNamed('mode'),
      webViewConfiguration: anyNamed('webViewConfiguration'),
      webOnlyWindowName: anyNamed('webOnlyWindowName'),
    )).called(1);
  });
}