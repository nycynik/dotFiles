# My dotfiles

There are quite a few dotfiles [out there in the world](https://dotfiles.github.io/), but this one is mine.

Built for development.

*Python | PHP | Java | Node | Dart | Swift*

![Script Output Example](https://mikelynchgames.com/wp-content/uploads/2025/03/image-1.png)

[More Information about this repository](http://mikelynchgames.com/software-development/setting-up-a-new-mac-for-development/)

# How To Use

Step1: Check out the repo in your home dir, that will make a hidden directory called .dotfiles in home.

     cd ~
     git git@github.com:nycynik/dotFiles.git .dotfiles

Step2: Run the setup file and follow the prompts

     . .dotfiles/setup.sh

# Updates?

Notes:
* You can add anything to the scripts directory, and it will be copied into the users bin directory.
* You can add any aliases to aliases, and functions to functions, and they will be added to your shell by default.

# Future Ideas

* Check out the [wiki](https://github.com/nycynik/dotFiles/wiki)

# Installed Components

## Terminal Configuration

This defaults you to [zsh](https://www.zsh.org/), and [oh-my-zsh](https://ohmyz.sh/). This also installs [powerlevel10k](https://github.com/romkatv/powerlevel10k) theme for zsh. [fish](https://fishshell.com/ is not included, as zsh 'just works' and is still the default shell for OSX.

[Git](https://git-scm.com/) is configured, or installed if it is missing. [pre-commit](https://pre-commit.com/) a tool for git repos, by including a pre-commit hook pre-commit will run lint/tests prior to allowing pushes to the repo. It's added to the 'dev' (source ~/.venv/dev/bin/activate) virtual env that is also added.

A whole bunch of command line [alias](./aliases)' are configured, and a small set of [functions](./functions).

It also adds a bin directory to your home, and a scripts directory, and adds some simple scripts to the folder, and adds bin to your path.

## Homebrew

[Homebrew](https://brew.sh/) (brew) works on all the OSes managed by this script, so it's a great choice. I love brew, and most packages are there, including casks, and cross-platform support all make it a great option.

## IDEs

There are three IDEs installed or configured by this script.  [Xcode](https://developer.apple.com/xcode/), [Android Studio](https://developer.android.com/studio), and [VSCode](https://code.visualstudio.com/).

## Docker

[Docker](https://www.docker.com/) is installed, and allows for all sorts of fun as a developer. Aside from installing it, no containers are created, that is left up to you :)

# Installed Languages

This covers all the top languages, in current rank order at the time of this writing, we are only missing one.. JavaScript, Python, Java, C#, PHP, C/C++. In 8th-10th place is Go, SQL, and Dart. Dart is included, and SQL is also included, as it's not a stand alone language that you use with a compiler.

[DotNet](https://dotnet.microsoft.com/en-us/) is the only one not included, sorry MS! I'm a mobile and web developer primarly. As an amatur game developer, I've used C# with Unity, but I've not needed it stand alone.

## C & C++

C and C++ are not specifically called out in the script. But VSCode can work with C/C++ (not as great as CLion), as well as xCode. So you can work with them. Developer tools are also installed (make, clang, gnu c compiler) So go ahead get going with C++!

## Flutter Development

Flutter dev includes [fvm](https://fvm.app/) as an SDK manager, this is important to have so that you can see how the app works on newer versions of the SDK (previews, etc) and that you can maintain your apps, by keeping the older versions that at times devices get stuck on.

[CocoaPods](https://cocoapods.org/) (pods) is included for dependency management for Swift and Flutter development.

Android development is mostly managed by Android Studio.

## JavaScript

~~Node development includes [nvm](https://github.com/nvm-sh/nvm) for managing node SDKs.~~
[pnpm](https://pnpm.io/) for a JavaScript package manager. pnpm can also manage node versions, so trying to just use that.

## Java

Java development uses [jenv](https://github.com/jenv/jenv) for SDK management. Java itself varies by machine, but [OpenJDK](https://openjdk.org/) is installed.

[Apache Maven](https://maven.apache.org/) (mvn) is included for project management. [Gradle](https://gradle.org/) is also installed as some projects use this or mvn, so both are added. Gradle may be the future, but maven is still used on some of my projects.

## PHP

[PHP](https://www.php.net/) is most commonly associated for me with WordPress, but there are lots of reasons PHP is popular. PHP 8 is installed, as well as composer.  [Composer](https://getcomposer.org/) is a dependecy manager for PHP.

## Python

Python development is supported by [uv](https://github.com/astral-sh/uv). This is a combination tool that replaces pip, pipx, pyenv, and virtualenv. That is a lot of tools, and so it's a bit more complex than some other tools, however it's so fast (written in Rust) and once you get the hang of it, you are going to love it.

I did not install [Anaconda](https://docs.conda.io/) as part of the script, simply becuase I don't find myself using it very much, as most of my projects use some form of pip.

# Ruby

[Ruby](https://www.ruby-lang.org/en/) is installed to the latest version (or multiple versions are installed) and [asdf](https://rvm.io/) is added to manage the versions. Bundler is also installed.
