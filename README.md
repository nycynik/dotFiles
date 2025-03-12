# My dotfiles

There are quite a few dotfiles [out there in the world](https://dotfiles.github.io/), but this one is mine.

Built for development.

*Python | Java | Node | Dart | Swift*

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

# Installation Notes

## Flutter Development

Flutter dev includes [fvm](https://fvm.app/) for managing multiple SDKs, this is important to have so that you can see how the app works on newer versions of the SDK (previews, etc) and that you can maintain your apps, by keeping the older versions that at times devices get stuck on.
