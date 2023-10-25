The following is a set of guidelines for contributing to the Angeleno My Account project. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

# Table of Contents
1. [How to Contribute](#how-to-contribute)
2. [Testing](#testing)
3. [Submitting Changes](#submitting-changes)
4. [Reporting bugs or requesting features](#reporting-bugs-or-requesting-features)

## How to Contribute
If you need to set up your local environment for development, please read the instructions on our [README.md](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/blob/main/README.md). All work submitted must be accompanied by a related Issue.

## Testing
You should run all tests prior to pushing any commits up to the remote branch. The repository has a [tests.bat](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/blob/main/tests.bat) file that will run the tests locally - these tests reflect the tests run by Github Actions and they must be passed in order to merge any pull requests. Our testing suite includes unit tests, found in the [test](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/tree/main/test) directory, and static analysis that holds you to our linting rules, found in the [analysis_options.yaml](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/blob/main/README.md) file.

## Submitting Changes
Once you are ready, open a pull request. Maintainers of the project will then review your submission via a code check/code review.

## Reporting bugs or requesting features
If a security vulnerability has been discovered, do not open a GitHub issue, instead reference our [security policy](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/blob/main/SECURITY.md).

If the bug you’ve found does not have an existing issue, [create one](https://github.com/CityOfLosAngeles/angeleno-my-account-flutter/issues/new/choose) using one of the appropriate issue templates. Be sure to add information requested by the template you’re using; include a descriptive title and description along with any identifying information such as any test cases, specific browsers, and/or steps to recreate the problem.

If you’re requesting a feature, open an issue with the appropriate template and include details like why the feature is important, if there are any workarounds available, what problem it solves, etc.