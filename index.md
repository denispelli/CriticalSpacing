## How to use CriticalSpacing to measure an observer's critical spacing and acuity for single and repeated targets. 

`CriticalSpacing.m` is a MATLAB program developed in the Pelli lab at NYU. In
order to run CriticalSpacing on your machine, please do the following:

1. Install MATLAB (or GNU Octave) and Psychtoolbox. If you haven't
   already installed, you can find detailed instructions here:
   [bit.ly/SetupPsychtoolbox](https://github.com/hyiltiz/ObjectRecognition/blob/master/README.md)
1. Download the CriticalSpacing software
   [here](https://github.com/denispelli/CriticalSpacing/archive/v0.3.zip).
1. Extract the `zip` archive, producing a folder called CriticalSpacing.
1. Copy the font file `Sloan.otf` from the `CriticalSpacing` folder to
   one of your computer OS font folders.  *Restart MATLAB* so that the
   newly installed font is noticed by MATLAB. 
1. Deal with remote typing. The observer must be 3 m (or more) away from
   the screen, and thus unable to reach a laptop keyboard attached to
   the screen. The quickest way to overcome this is for the experimenter
   to type what the observer says. A more convenient solution is to get
   a wireless or long-cable keyboard. In that case,  connect the
   keyboard to your computer, and *Restart MATLAB*. Try
   `GetKeyboardIndex` to see if the keyboard is registered to MATLAB
   (the number of outputs is the number of keybaord devices registered
   to MATLAB; so we are looking for at least 2 numbers). 
1. Print the `Response Page`. Inside the `CriticalSpacing` folder you'll
   find a file `Response page.pdf` that should be printed and given to
   the observer.  It shows the possible letters: `DHKNORSVZ`. Adults
   will find it helpful to consult this page while choosing an answer
   when they have little idea what letter the target(s) might be.
   Children may prefer to point at the target letters, one by one, on
   the response page.
1. Make sure the computer is connected to power. Data will be lost if
   the computer hibernates or goes to "sleep" before the program
   finishes.
1. To test an observer, double click `runCriticalSpacing`. Say "Ok" if
   MATLAB offers to change the current folder. The program automatically
   saves the data to the `data` folder. The test takes 10 to 20 min to
   test one observer (depending on trials per threshold), measuring four
   thresholds. (Set o.trials to 20 or 40 for a total runtime of 10 or 20
   minutes.)


## Software requirements:

CriticalSpacing, Psychtoolbox, and MATLAB


> Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
