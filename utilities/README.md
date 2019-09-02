## You can use the MATLAB program TestFlip.m on your computer to assess the timing of the Psychtoolbox Screen Flip display command. TestFlip plots the results, and saves the plot in a PNG file with a file name that identifies the computer and software environment. The "png" folder contains all the results that everyone has sent me so far, including macOS, Windows, and Linux. Please send me yours, for addition to the folder.

"TestFlip.m" is a MATLAB program developed by Denis Pelli at NYU. You can read more about it in the Psychtoolbox forum.

"png" is a folder with all the PNG files I've received with results from running TestFlip on a variety of computers. 

"mat" is a folder with all the MAT files that result from running TestFlip on a variety of computers. It's just raw timing data. Hardly anyone will be interested in this.

IdentifyComputer.m. To identify the computer and software environment, TestFlip.m uses the  function IdentifyComputer, provided as a separate file IdentifyComputer.m. It currently supports macOS and Windows. I hope someone can extend it to support Linux.

InstallationCheck.m is unrelated. We use it to check that a computer has all the necessary software installed to run an experiment.

I am offering both TestFlip.m and IdentifyComputer.m to be incorporated into the Psychtoolbox. 

THANKS to Darshan Thapa, Augustin Burchell, Sangita Chakraborty, and iandol@gmail.com for sending PNG files now included in the png folder.

## TestFlip.m is self contained. All you need is TestFlip.m, the Psychtoolbox, and MATLAB (or Octave).

## Software required:

TestFlip.m, Psychtoolbox, and MATLAB (or Octave)

## Hardware required:

* A computer running Mac OS X, Windows, or Linux, with the above software installed. 

## Update:
* August 27, 2019. DGP Made available through GitHub.
* September 1, 2019. DGP Renamed ComputerModelName to IdentifyComputer.


&copy; Copyright 2019 Denis Pelli, denis.pelli@nyu.edu
