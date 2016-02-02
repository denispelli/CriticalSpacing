## How to use CriticalSpacing to measure an observer's critical spacing and acuity for single and repeated targets.

“CriticalSpacing.m” is a MATLAB program developed by Denis Pelli at NYU, with help from Hörmet Yiltiz. In order to run CriticalSpacing on your machine, please do the following:

1. INSTALL MATLAB (or GNU Octave) and Psychtoolbox. If you haven't
   already installed, you can find detailed instructions here:
[bit.ly/SetupPsychtoolbox](https://github.com/hyiltiz/ObjectRecognition/blob/master/README.txt)
1. DOWNLOAD the CriticalSpacing software:
[https://github.com/denispelli/CriticalSpacing/archive/v0.3.zip](https://github.com/denispelli/CriticalSpacing/archive/v0.3.zip)
1. UNPACK the “zip” archive, producing a folder called CriticalSpacing.
1. RUN A SCRIPT. To test an observer, double click “runCriticalSpacing.m” or your own modified script. They're easy to write. Say "Ok" if MATLAB offers to change the current folder. CriticalSpacing automatically saves your results to the “CriticalSpacing/data” folder. The filenames are unique and intuitive, so it's ok to let lots of data accumulate in the data folder. runCriticalSpacing takes 5 min to test one observer (with 20 trials per threshold), measuring two thresholds, interleaved. 
1. WIRELESS KEYBOARD. A normally sighted observer viewing foveally has excellent vision and must be many meters away from the screen, and thus will be unable to reach a built-in keyboard attached to the screen. The quickest way to overcome this is for the experimenter to type what the observer says. A more convenient solution is to get a wireless or long-cable keyboard. 
1. VIEWING DISTANCE. You can provide a default in your script, e.g. o.viewingDistanceCm=400. CriticalSpacing invites you to modify the viewing distance (or declare that you're using a mirror) at the beginning of each run. Please err on the side of making the viewing distance longer than necessary. If you use too short a viewing distance then the minimum size and spacing may be bigger than the threshold you want to measure. CriticalSpacing.m warns you at the end of the run if the estimated threshold is smaller than the minimum possible size or spacing at the current distance, and suggests that you increase the viewing distance in subsequent runs.
1. SKIPPING A TRIAL: To make it easier for children, we’ve softened the "forced" in forced choice. If you (the experimenter) think the observer is overwhelmed by this trial, you can press the spacebar instead of a letter and the program will immediately go to the next trial, which will be easier. If you skip that trial too, the next will be even easier, and so on. However, as soon as a trial gets a normal response then Quest will resume presenting trials near threshold. We hope skipping will make the initial experience easier. Eventually the child must still do trials near threshold, because threshold estimation requires it. Skipping is always available. If you type one letter and then skip, the typed letter still counts. There’s an invisible timer. If you hit space (to skip) less than 8 s after the chart appeared, then the program says "Skip", and any responses not yet taken do not count. If you wait at least 8 s before hitting space, then the program says “Space” and, supposing that the child felt too unsure to answer, the program “helps” by providing a random guess. By chance, that guess will occasionally be right.
1. NAMING THE EXPERIMENTER & OBSERVER. If it doesn't already know, CriticalSpacing asks for the name of the experimenter and observer. These names are included in the data files, and incorporated into the data file names. If your know the experimenter or observer name in advance you can specify it in your script, e.g. o.experimenter='Denis' or o.observer='JohnK', and CriticalSpacing will skip that question.
1. THRESHOLD ORIENTATION. Use o.measureThresholdVertically=1; (or =0) to report threshold (size or spacing) vertically or horizontally. The ratio SpacingOverSize always measures both spacing and size along the same axis. The final report by CriticalSpacing includes the aspect ratio of your font: heightOverWidth.
1. FONT. Choose a font from those available in the CriticalSpacing/pdf/ folder. They are all available if you set o.readAlphabetFromDisk=1. We recommend "Pelli" for threshold spacing and Sloan for threshold size. Print the PDF for your font, e.g. “Pelli alphabet.pdf” or “Sloan alphabet.pdf”. Give the printed alphabet page to your observer. It shows the possible letters, e.g. “DHKNORSVZ” or “1234567889”. Observers will find it helpful to consult this page while choosing an answer when they have little idea what letter the target(s) might be. And children may prefer to point at the target letters, one by one, on the alphabet page.
1. OPTIONAL: ADDING A NEW FONT. Running the program SaveAlphabetToDisk in the CriticalSpacing/lib/ folder, after you edit it to specify the font, alphabet, and borderCharacter you want, will add a snapshot of your font's alphabet to the pdf folder and add a new folder, named for your font, to the alphabets folder.
1. OPTIONAL: USING YOUR COMPUTER'S FONTS, LIVE. Set o.readAlphabetFromDisk=0. You may wish to install Pelli or Sloan from the CriticalSpacing/fonts/ folder. Restart MATLAB after installing a new font. 

## Software requirements:

CriticalSpacing, Psychtoolbox, and MATLAB

## Hardware requirements:

A laptop running Mac OS X, Windows, or Linux, with the above software installed. 
(Or a digital screen driven by a computer with such software. We need the digital screen in order for the computer to tell CriticalSpacing.m the screen size and resolution.)
A remote keyboard: wireless or with a 10-m-long cable.
A 10 m measuring tape to measure the viewing distance.
A printed copy of the relevant alphabet page selected from CriticalSpacing/pdf folder.


> Copyright 2015, 2016, Denis Pelli, denis.pelli@nyu.edu
