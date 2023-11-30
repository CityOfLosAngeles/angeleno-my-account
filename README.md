# Angeleno - Profile
<a href="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/actions"><img src="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/workflows/Dart%20Analyzer/badge.svg" alt="Dart Analyzer Status"></a>
<a href="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/actions"><img src="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/workflows/Flutter%20Unit%20Tests/badge.svg" alt="Flutter Tests Status"></a>

## Getting Started
This branch should act as our main branch until we have a working Minimum Viable Product (MVP) to merge into the `main` branch. To start development you'll `git clone` this repo; after cloning you'll by default be on the main branch, but you can `git checkout mvp-skeleton` to switch to the branch with the code being worked on. From the `mvp-skeleton` branch, you can branch off to work on your own work/issue by running `git checkout -b your-branch-name`. When opening the pull request for your work, make sure the branch is being merged into `mvp-skeleton` and not `main`.

## Development

### Flutter Environment
After downloading the [Flutter SDK](https://docs.flutter.dev/get-started/install), you'll be able to run
`flutter doctor` which will give you details on anything you need to develop the application. As this app is only web-based for now you can safely ignore warnings around developing for Windows, Android, iOS, etc.

Making updates to `.dart` files will require you to run `flutter build web` so that the web app can recompile.

After building, you can use `flutter run -d chrome` to run on Chrome. You can add additional devices (browsers) for additional testing.

If you need to specify a web port to run the app on, you can append the argument `--web-port=####` to the above - this will be helpful when testing redirects from external apps as it'll allow us to control a designated port.

In order for the code to pick your environment variables, you'll have to append `--dart-define-from-file=.env` to your flutter run command.

Running `flutter analyze` will check your code to make sure it aligns with our linting rules.

### Local Development
Rename the `.env-example` file to `.env` and fill in the required environment variables.

In Auth0, you'll want to create a Single Page Application to get the appropriate values for the `.env` file.

If you're using a cloud function without authorization, you will not need the Service Account variables, but the code will have to be modified.

The cloud functions being used can be found in the `functions` directory. To run them locally, you can find instructions [here](https://firebase.google.com/docs/functions/local-emulator). Once you have the functions running locally, you'll have to update the code in the locations where the request is sent so that it points to your emulator.