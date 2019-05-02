function [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo,textMarginPix)
% [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo,textMarginPix);
% Copied from NoiseDiscrimination to CriticalSpacing, and modified just
% enough to work.
% May 1, 2019, denis.pelli@nyu.edu
if nargin<2
    error('Need at least 2 args.');
end
o=oo(1);
if true
    % Set up default values for parameters from NoiseDiscrimination that
    % are not defined in CriticalSpacing.
    % o.useSpeech is defined in CriticalSpacing.
    o.speakEachLetter=false; % Not used in CriticalSpacing.
    o.gray1=255; % Not used in CriticalSpacing.
    if ~isfield(o,'textFont') || isempty(o.textFont)
        o.textFont='Arial';
    end
    if ~isfield(o,'textSize')
        o.textSize=TextSizeToFit(window); % Set optimum text size in NoiseDiscrimination.
    end
end
assert(isfield(o,'textFont') && ~isempty(o.textFont));
if o.speakEachLetter && o.useSpeech
   Speak('Escape');
end
if nargin<3
    textMarginPix=2*o.textSize;
end
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
returnChar=char(13);
graveAccentChar='`';
backgroundColor=o.gray1;
Screen('FillRect',window,backgroundColor);
Screen('TextFont',window,o.textFont,0);
Screen('TextSize',window,o.textSize);
black=0;
Screen('Preference','TextAntiAliasing',0);
Screen('FillRect',window);
y=0;
if isfield(o,'trials') && isfield(o,'trialsPerBlock')
    % Used by NoiseDiscrimination. I prefer DrawCounter.
    trials=sum([oo.trials]);
    trialsDesired=sum([oo.trialsPerBlock]);
    if isfield(o,'block') && isfield(o,'blocksDesired') && isfield(o,'textSize')
        message=sprintf('Trial %d of %d. Block %d of %d.',trials,trialsDesired,o.block,o.blocksDesired);
        if isfield(o,'experiment')
            message=[message ' Experiment "' o.experiment '".'];
        end
        Screen('DrawText',window,message,o.textSize/2,o.textSize/2,black,backgroundColor);
        y=o.textSize;
    end
else
    % Used by CriticalSpacing.
    DrawCounter(oo);
end
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
if ~isfield(o,'isLastBlock')
    o.isLastBlock=isfield(o,'block') && isfield(o,'blocksDesired') && o.block>=o.blocksDesired;
end
if o.isLastBlock
    nextBlockMsg='';
else
    nextBlockMsg='Or hit RETURN to proceed to the next block. ';
end
if nargout==3
   nextTrialMsg='Or hit SPACE to proceed to the next trial.';
else
   nextTrialMsg='';
end
%     'Hit RETURN to proceed to the next block. ' 
string=['You escaped. Any incomplete trial was canceled. ' ...
    'Hit ESCAPE again to quit the whole experiment. '...
    nextBlockMsg nextTrialMsg];
DrawFormattedText(window,string,textMarginPix,1*o.textSize+y,black,60,[],[],1.1);
Screen('Flip',window);
answer=GetKeypress([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
quitExperiment=ismember(answer,[escapeChar,graveAccentChar]);
quitBlock=ismember(answer,returnChar)||quitExperiment;
skipTrial=ismember(answer,' ');
if o.useSpeech
    if quitExperiment || quitBlock && oo(1).isLastBlock
        Speak('Done.');
    elseif quitBlock
        Speak('Proceeding to next block.');
    elseif skipTrial
        Speak('Proceeding to next trial.');
    end
end
Screen('FillRect',window);
end