# Angeleno - Profile

## Getting Started
After downloading the [Flutter SDK](https://docs.flutter.dev/get-started/install), you'll be able to run 
`flutter doctor` which will give you details on anything you need to develop the application. As this app is only web-based
for now you can safely ignore warnings around developing for Windows, Android, iOS, etc.

Making updates to `main.dart` will require you to run `flutter build web` so that the web app can recompile.

After building, you can use `flutter run -d chrome` to run on Chrome. You can add additional devices (browsers)
for additional testing.

If you need to specify a web port to run the app on, you can append the argument `--web-port=####` to the above - this
will be helpful when testing redirects from external apps.