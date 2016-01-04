## How to use CriticalSpacing to measure an observer's critical spacing and acuity for single and repeated targets. 

`CriticalSpacing.m` is a MATLAB program developed in the Pelli lab at NYU. In
order to run CriticalSpacing on your machine, please do the following:

1. Install MATLAB (or GNU Octave) and Psychtoolbox. If you haven't
   already installed, you can find detailed instructions here:
   [bit.ly/SetupPsychtoolbox](https://github.com/hyiltiz/ObjectRecognition/blob/master/README.txt)
1. Download the CriticalSpacing software
   [here](https://github.com/denispelli/CriticalSpacing/archive/v0.3.zip).
1. Extract the `zip` archive, producing a folder called CriticalSpacing.
1. OPTIONAL, NOT NEEDED IF YOU SET readAlphabetFromDisk=1. 
   Copy the desired font file or folder (e.g. `Sloan.otf` or ‘GothamCondensed’) 
   from the  `CriticalSpacing/font` folder to
   one of your computer OS font folders.  *Restart MATLAB* so that the
   newly installed font is noticed by MATLAB. 
1. Deal with remote typing. The observer must be 2 m (or more) away from
   the screen, and thus unable to reach a laptop keyboard attached to
   the screen. The quickest way to overcome this is for the experimenter
   to type what the observer says. A more convenient solution is to get
   a wireless or long-cable keyboard. In that case,  connect the
   keyboard to your computer, and *Restart MATLAB*. Try
   `GetKeyboardIndex` to see if the keyboard is registered to MATLAB
   (the number of outputs is the number of keyboard devices registered
   to MATLAB; so you are hoping for at least 2 numbers). If MATLAB Command 
   Window responds to the keyboard, but CriticalSpacing.m does not, try 
   quitting and restarting MATLAB. 
1. Choose a font, currently Sloan or Gotham. Print the `Response Page` 
   PDF for your font. Inside the `CriticalSpacing` folder you'll
   find files `Response page for Sloan.pdf` and `Response page for Gotham.pdf`.
   Print the appropriate one and give it to your observer. The response page 
   shows the possible letters, e.g. `DHKNORSVZ` or ‘1234567889’. Adults
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
1. Threshold width. When you ask CriticalSpacing.m to measure "size", the 
   program   always measures it vertically, so, in that case, the returned 
   "size" is height. Thus the reported threshold is height, and you should 
   compute width:
   width = height / heightOverWidth;
1. Threshold width continued. When you ask to measure “spacing”, by default 
   it’s horizontal. The ratio
   SpacingOverSize always measures both along the same axis, usually 
   horizontally. So the letter width at threshold spacing is:
   width = spacing/SpacingOverSize;

## Software requirements:

CriticalSpacing, Psychtoolbox, and MATLAB


> Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
