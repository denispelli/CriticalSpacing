## How to use CriticalSpacing to measure an observer's critical spacing and acuity for single and repeated targets.

“CriticalSpacing.m” is a MATLAB program developed by Denis Pelli at NYU, with some help from Hörmet Yiltiz. In order to run CriticalSpacing on your machine, please do the following:

1. Install MATLAB (or GNU Octave) and Psychtoolbox. If you haven't
   already installed, you can find detailed instructions here:
[bit.ly/SetupPsychtoolbox](https://github.com/hyiltiz/ObjectRecognition/blob/master/README.txt)
1. Download the CriticalSpacing software
   [here](https://github.com/denispelli/CriticalSpacing/archive/v0.3.zip).
1. Extract the “zip” archive, producing a folder called CriticalSpacing.
1. OPTIONAL, NOT NEEDED IF YOU SET o.readAlphabetFromDisk=1. 
   Copy the desired font file or folder (e.g. “Sloan.otf” or “GothamCondensed”) 
   from the  “CriticalSpacing/font” folder to one of your computer OS font 
   folders. Restart MATLAB so that the newly installed font is noticed by MATLAB. 
1. Allow remote typing. A normally sighted observer must be 2 m (or more) 
   away from the screen, and thus will be unable to reach a laptop keyboard 
   attached to the screen. The quickest way to overcome this is for the experimenter
   to type what the observer says. A more convenient solution is to get
   a wireless or long-cable keyboard. In that case, connect the keyboard
   to your computer, and restart MATLAB. “GetKeyboardIndex” will tell you whether
   the keyboard is registered to MATLAB (the number of outputs is the 
   number of keyboard devices registered to MATLAB; so you are hoping for 
   at least 2 numbers). If the MATLAB Command Window responds to the keyboard, 
   but CriticalSpacing.m does not, try quitting and restarting MATLAB. 
1. Choose a font. We recommend "Pelli" for threshold spacing and Sloan for 
   threshold size. Print the “Response Page” PDF for your font. Inside 
   the “CriticalSpacing” folder you'll
   find files “Response page for Pelli.pdf” and “Response page for Sloan.pdf”.
   Print the appropriate one and give it to your observer. The response page 
   shows the possible letters, e.g. “DHKNORSVZ” or “1234567889”. Observers
   will find it helpful to consult this page while choosing an answer
   when they have little idea what letter the target(s) might be.
   And children may prefer to point at the target letters, one by one, on
   the response page.
1. Make sure the computer is connected to power. Data will be lost if
   the computer hibernates or goes to "sleep" before the program
   finishes.
1. To test an observer, double click “runCriticalSpacing” or your own modified 
   script; they're easy to write. Say "Ok" if
   MATLAB offers to change the current folder. The program automatically
   saves the data to the “CriticalSpacing/data” folder. The test takes 10 min to
   test one observer (with 10 trials per threshold), measuring four
   thresholds. (You can increase o.trials from 20 to 40 for a more precise threshold
   estimate.)
1. SIZE THRESHOLD. Use o.measureThresholdVertically=0; to measure (i.e. report) the size 
   horizontally. Height and width are related by
   width = height / heightOverWidth;
1. SPACING THRESHOLD. When you ask to measure “spacing”, by default it’s horizontal. 
   The ratio SpacingOverSize always measures both spacing and size along the same 
   axis, usually horizontally. 
1. VIEWING DISTANCE. You can provide a default in your script, e.g. 
   o.viewingDistanceCm=400;
   You are invited to modify the viewing distance at the beginning of each 
   run. Please err on the side of making the viewing distance longer than 
   necessary. If you use too short a viewing distance then the minimum 
   size and spacing may be bigger than the threshold you want to measure.
   CriticalSpacing.m warns you at the end of the run if the estimated 
   threshold is smaller than the minimum size or spacing, and suggests that you 
   increase the viewing distance in subsequent runs.
1. SKIPPING A TRIAL FOR CHILDREN: To make it easier for children, 
   we’ve softened the "forced" in forced choice. If you (the experimenter) 
   think the child is overwhelmed by this trial, you can press the spacebar instead of 
   a letter and the program will immediately go to the next trial, and make that trial 
   easier. If you skip that trial too, the next will be even easier, and so on. However, 
   as soon as a trial gets a normal response then Quest will kick back in and resume 
   presenting trials near threshold. We hope skipping will make the initial experience 
   easier. Eventually the child must still do trials near threshold, because 
   threshold estimation requires it. Skipping is always available. 
   If you type one letter and then skip, the letter still counts. And there’s a timer. 
   If you hit space less than 8 s after the chart appeared, then the program says "Skip", 
   and any responses not yet taken do not count. If you wait at least 8 s before 
   hitting space, then the program says “space” and, supposing that the child felt 
   too unsure to answer, the program “helps” by providing a random guess. 

## Software requirements:

CriticalSpacing, Psychtoolbox, and MATLAB

## Hardware requirements:

A laptop running Mac OS X, Windows, or Linux, with the above software installed. 
(Or a digital screen driven by a computer with such software. We need the digital screen in order for the computer to tell CriticalSpacing.m the screen size and resolution.)
A remote keyboard: wireless or with a 10-m-long cable.
A 10 m measuring tape to measure the viewing distance.
A printed copy of the relevant Response page selected from CriticalSpacing/response pages.


> Copyright 2015, 2016, Denis Pelli, denis.pelli@nyu.edu
