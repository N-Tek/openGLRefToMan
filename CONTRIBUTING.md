# Contributing Guidelines

## Introduction

I'd like to thank you for your interest in contributing. All types of contributions
are encouraged and valued.

## How to help and where?

* Checking for typos in the documentation related with the project
* Checking for typos shell scripts comments
* Suggestions related with the coding style of shell scripts
* Suggestions to improve the performance of the shell scripts
* Checking for typos in corrected manpages
* Suggestions to improve the readability of corrected manpages
* Adding new corrected manpages as the original OpenGL-Reference repo gets updated

## How can I contribute?

This project uses GitHub issues for handling issue reports, bug reports, 
replying feature and support requests; GitHub pull requests for pull requests.

Please make sure you do the following before opening an issue or a pull request:

* Be sure to review [code of conduct](./CODE_OF_CONDUCT.md).
* Please search existing issues before filing new issues to avoid duplicates.
* If you're not satisfied and/or can't find what you're looking for by filing one
  of the related templates open an issue at [here](https://github.com/N-Tek/openGLRefToMan/issues) / open a pull request at [here](https://github.com/N-Tek/openGLRefToMan/pulls).

For other types of contributions please file them by filling the blank issue report
with necessary information.

Once it's filed:

* Maintainer will try to reply soon.

## Technical Project Structure
### Coding style guidelines  
If you want to contribute some type of code please check it with the appropriate
linter and then send a pull request.

Don't use capitalized variable names in shell scripts if they're not environmental
variables

### Workflow  
**_gitflow_** is the preferred type of workflow implemented in this project.

### Branch organisation  
Only the `master` branch will be shared in this repo with the community.

### Versioning  
[Semantic Versioning 2.0.0](https://semver.org) is the effective versioning method
used for this project.

### Testing  
Make sure, changes introduced in your pull request won't break the original software.

At least 2 times install and remove the updated SlackBuild script with your changes
by following the directives presented in [README.md](./README.md) and verify that
the system returns its initial state defined before the beginning of the testing
process.
