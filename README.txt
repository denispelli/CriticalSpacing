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
1. Threshold size. Use o.measureThresholdVertically=0; to measure (i.e. report) the size 
   horizontally. Height and width are related by
   width = height / heightOverWidth;
1. When you ask to measure “spacing”, by default it’s horizontal. The ratio 
   SpacingOverSize always measures both spacing and size along the same axis, usually 
   horizontally. 
1. SKIPPING A TRIAL FOR CHILDREN: To make it easier when testing children, 
   we’ve softened the "forced" in forced choice. If you (the experimenter) think
   the child is overwhelmed by this trial, you can press the spacebar instead of 
   a letter and the program will immediately go to the next trial, and make that trial 
   easier. If you that trial as well, it will be even easier, again and again. However, 
   as soon as a trial gets a normal response then Quest will kick back in and resume presenting trials
   near threshold. We hope skipping will make the initial experience easier. Eventually the child must
   still do trials near threshold, because threshold estimation requires it. Skipping is always available. 
   If you type one letter and then skip, the letter still counts. And there’s a timer. If you hit space 
   less than 8 s after the chart appeared, then the program says "Skip", and any responses not yet taken 
   do not count. If you wait at least 8 s before hitting space, then the program says “space” and, 
   supposing that the child felt too unsure to answer, the program “helps” by providing a random guess. 

## Software requirements:

CriticalSpacing, Psychtoolbox, and MATLAB


> Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
