# My dotfiles

There are quite a few dotfiles [out there in the world](https://dotfiles.github.io/), but this one is mine.

Built for MacOSX, mostly focused on development.

Python | Java | Node | Ruby

[Blog entry](http://mikelynchgames.com/software-development/setting-up-a-new-mac-for-development/)

# Basic use

Step1: Check out the repo in your home dir, that will make a hidden directory called .dotfiles in home.

     cd ~
     git clone --depth=1 git@github.com:nycynik/dotFiles.git
     rm -rf ./.dotfiles/.git
     
Step2: Run the setup file and follow the prompts

     . ./setup.sh
     

# Future Ideas

* Check out the [wiki](https://github.com/nycynik/dotFiles/wiki)
* Swap over to zsh

