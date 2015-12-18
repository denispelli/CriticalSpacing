% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
o.setTargetHeightOverWidth=0;
o.thresholdParameter='spacing';
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=230;

% MIRROR: In a small room, you can use a mirror to achieve a long viewing
% distance. This switch tells our software to display a mirror image, so
% that the observer looking in your mirror will see normally oriented
% letters.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.

% For normal adults we use the restricted standard Sloan alphabet
% (excluding C, which has been shown to be too similar to O).
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';

% Skinny letters are better for testing critical spacing.
% o.alphabet='7ij:()[]/|'; % bar-symbol alphabet
% o.validKeys = {'7&','i','j',';:','9(','0)','[{',']}','/?','\|'};
% o.borderLetter='!';

o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.

% SPEAK ENCOURAGEMENT. This speaks an encouraging word after every trial,
% regardless of accuracy. I anticipate that young children will like this,
% whereas adults might not.
o.speakEncouragement=0; % Say "good," "very good," or "nice" after every trial.

% SPEAK EACH LETTER. For testing children, I think it helps to give
% auditory acknowledgement of each letter selected (typed). Adult
% participants who type the answers themselves may prefer silence. So this
% is optional.
o.speakEachLetter=1;

% SPEECH. Some environments require silence, and Octave (like MATLB) on
% Linux does not currently support the Psychtoolbox Speak.m command.
% Turning this off suppresses all speech (except for debugging).
% Positive-feedback beeps, which are not speech, are not affected.
o.useSpeech=1;

% I like getting a positive beep for right, and nothing for wrong. The
% current purring sound is not attractive enough, so I prefer silence.
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0;

% You don't need to change any of these parameters.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.readLettersFromDisk=0; % 1 makes the program more portable.
o.usePurring=0; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.negativeFeedback=0;
o.fixationCrossDeg=0;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.task='identify';
o.minimumTargetPix=8; % Make sure the letters are well rendered.
o.targetFont='Sloan';
% o.targetFont='ClearviewText';
o.targetFont='Gotham Cond SSm Medium';
% o.targetFont='Gotham Cond SSm Book';
% o.targetFont='Retina Micro';
% o.targetFont='Calibri';
o.alphabet='123456789'; 
o.borderLetter='0';
o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};

o.textFont='Calibri';
o.fixationLocation='center';

% DEBUGGING AIDS
o.showLineOfLetters=0;
o.showBounds=0;
o.speakSizeAndSpacing=0;
o.frameTheTarget=0; % For debugging.
o.useFractionOfScreen=0; % For debugging.
o.printSizeAndSpacing=0; % For debugging.
o.displayAlphabet=0; % For debugging.

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.

% FIRST RUN (measures two thresholds, interleaved)
o.repeatedTargets=1;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(1).fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o(2).fixedSpacingOverSize=1.2; % Requests size proportional to spacing.
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely

% SECOND RUN (measures two thresholds, interleaved)
% We retain the observer name obtained during the first run for use in the
% second run.
o=o(1);
o.thresholdParameter='size';
o.repeatedTargets=0;
oSingle=CriticalSpacing(o); % one target

% Results are printed in the command window and saved in the "data" folder
% within the folder that contains the CriticalSpacing.m program.
