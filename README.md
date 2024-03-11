# Angeleno - My Account
<a href="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/actions"><img src="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/workflows/Dart%20Analyzer/badge.svg" alt="Dart Analyzer Status"></a>
<a href="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/actions"><img src="https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/workflows/Flutter%20Unit%20Tests/badge.svg" alt="Flutter Tests Status"></a>
[![codecov](https://codecov.io/gh/CityOfLosAngeles/angeleno-my-account/graph/badge.svg?token=ILNR5XOM40)](https://codecov.io/gh/CityOfLosAngeles/angeleno-my-account)

## What is Angeleno Account?
An Angeleno Account acts as a single sign-on for our public to access multiple City of Los Angeles services that have decided to accept the Angeleno Account. 

## What is Angeleno - My Account?
Angeleno - My Account is a Flutter based app that interfaces Auth0. This repository is for setting up a Flutter Web Application on your machine to interface Auth0. With Auth0 you can authenticate and authorize user to access your applications. With this repository you will get a Auth0 Web login which then redirects back to the Flutter app in where the authenticated user can see their current profile along with make changes to their profile. We have added Google Places API to assist user's with autocompleting and validating their address.


## Getting Started
The develpment branch is our main branch you can use to work on your own work/issues. To start development you'll `git clone` this repo; after cloning you'll by default be on the development branch. When opening the pull request for your work, make sure the branch is being merged into `development` branch as well.


### Minimum Requirements
- Flutter >=3.16.0 [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Firebase Local Emulator Suite [Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- Google Cloud Account (https://cloud.google.com/)
  - Create Project and enable Places API
    - Places Autocomplete (https://developers.google.com/maps/documentation/places/web-service/autocomplete)
    - Places Details (https://developers.google.com/maps/documentation/places/web-service/details)
      - We will consider using Geocoding API for cost optimization (https://developers.google.com/maps/documentation/geocoding/overview#results)
      
- Firebase Account (https://firebase.google.com)
  - Enable and create functions for interfacing Auth0Web library
  - Create hosting for the site
- Auth0 Account (https://auth0.com/docs/get-started)
  - Create 2 Auth0 Apps:
    - Single Page App for authenticating sessions used for the Flutter Auth0Web library
    - Regular Web App for handling transactions with Auth0's API's (MFA, password changes, and writing user updates to Auth0)   



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

#### Commands
Needed for running project:
- flutter run -d chrome --web-port=50601 --dart-define-from-file=.env (You can change the web port)
- firebase emulators:start --only functions

Needed for syntax:
- dart analyze

Needed for running Unit Tests:
- flutter test
