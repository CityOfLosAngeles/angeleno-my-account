# Angeleno - Profile

## Getting Started
This branch should act as our main branch until we have a working Minimum Viable Product (MVP) to merge into the `main` branch. To start development you'll `git clone` this repo; after cloning you'll by default be on the main branch, but you can `git checkout mvp-skeleton` to switch to the branch with the code being worked on. From the `mvp-skeleton` branch, you can branch off to work on your own work/issue by running `git checkout -b your-branch-name`. When opening the pull request for your work, make sure the branch is being merged into `mvp-skeleton` and not `main`.

### Developing
 
After downloading the [Flutter SDK](https://docs.flutter.dev/get-started/install), you'll be able to run 
`flutter doctor` which will give you details on anything you need to develop the application. As this app is only web-based for now you can safely ignore warnings around developing for Windows, Android, iOS, etc.

Making updates to `.dart` files will require you to run `flutter build web` so that the web app can recompile.

After building, you can use `flutter run -d chrome` to run on Chrome. You can add additional devices (browsers) for additional testing.

If you need to specify a web port to run the app on, you can append the argument `--web-port=####` to the above - this will be helpful when testing redirects from external apps as it'll allow us to control a designated port.