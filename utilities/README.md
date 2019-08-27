## You can use the MATLAB program TestFlip.m on your computer to assess the timing of the Psychtoolbox Screen Flip display command. It plots the results, and saves the plot in a PNG file with a file name that identifies the computer and software environment. The "png files" folder contains all the results that everyone has sent me so far, including macOS, Windows, and Linux. Please send me yours, for addition to the folder.

"TestFlip.m" is a MATLAB program developed by Denis Pelli at NYU. You can read more about it in the Psychtoolbox forum.

"png files" is a folder with all the PNG files that result from running TestFlip on a variety of computers. This is the most interesting thing here.

"mat files" is a folder with all the MAT files that result from running TestFlip on a variety of computers. It's just raw timing data. Hardly anyone will be interested in this.

To identify the computer and software environment, TestFlip.m uses a subroutine ComputerModelName, within the file. It is also available as a separate file ComputerModelName.m.

InstallationCheck.m is unrelated. We use it to check that a computer has all the necessary software installed to run an experiment.

I have offered both TestFlip.m and ComputerModelName.m to be incorporated into the Psychtoolbox. 

## TestFlip.m is self contained. All you need is TestFlip.m, the Psychtoolbox, and MATLAB (or Octave).

## Software required:

TestFlip.m, Psychtoolbox, and MATLAB (or Octave)

## Hardware required:

* A computer running Mac OS X, Windows, or Linux, with the above software installed. 

## Update:
* August 27, 2019. DGP Made available through GitHub.

&copy; Copyright 2019 Denis Pelli, denis.pelli@nyu.edu
