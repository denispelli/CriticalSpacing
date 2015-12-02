## How to use

This code is developed in Pelli lab. Software development is hosted at
Github this [page](https://github.com/denispelli/CriticalSpacing). In
order to run this code in your machine, please do the following:

1. Install MATLAB R2015a (or GNU Octave 4.0) and Psychtoolbox 3.0.10.
   If you haven't already installed, You can find a detailed instruction
   here:
   [bit.ly/SetupPsychtoolbox](https://github.com/hyiltiz/ObjectRecognition/blob/master/README.md)
1. Download the latest tested software from this Github repository page.
   Go to **Releases** page, then look for the latest version, and click
   on `zip` to download a zipped archive.
1. You will have to view the screen from at least 3m distance. So please
   find an extended bluetooth or long cable keyboard. Connect the
   keyboard to your computer. *Restart MATLAB*. Try `GetKeyboardIndex`
   to see if the keyboard is registered to MATLAB (the number of outputs
   is the number of keybaord devices registered to MATLAB; so we are
   looking for at least 2 numbers).
1. Extract the `zip` archive. Then from MATLAB, change *Current
   Directory* to the extracted archive.
1. Type `runCriticalSpacing` to run the program. The program will save
   the data to the `data` folder automatically. The program will run
   about 20min for each observer. Please make sure the computer is
   connected to power. The data will be lost if the computer hibernates
   or goes to "sleep" mode before the program exists successfully.
1. Have fun!


## Software Requirements

All versions in the *Releases* page is tested under the platforms below.
Versions close to the ones below might *also work*. You may test your
own platform (it may just work!) before upgrading your software.

- Psychtoolbox 3.0.10
- MATLAB R2015a, R2015b (or GNU Octave 4.0)
- OS X El Capitan, Windows 8.1, Debian Testing (Linux 4.2)


> Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
