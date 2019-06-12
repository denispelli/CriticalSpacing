function [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo)
% [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo);
% Copied from NoiseDiscrimination to CriticalSpacing, and modified just
% enough to work.
% May 1, 2019, denis.pelli@nyu.edu
o=oo(1);
if nargin<2
    error('Need at least two args.');
end
if true
    % Set up default values for parameters from NoiseDiscrimination that
    % are not defined in CriticalSpacing.
    % o.useSpeech is defined in CriticalSpacing.
    o.speakEachLetter=false; % Not used in CriticalSpacing.
    o.gray1=255; % Not used in CriticalSpacing.
    if ~isfield(o,'textFont') || isempty(o.textFont)
        o.textFont='Verdana';
    end
    if ~isfield(o,'textSize') || ~isfield(o,'textLineLength')
        [o.textSize,o.textLineLength]=TextSizeToFit(window,o.textFont); % Set optimum text size in NoiseDiscrimination.
        fprintf('OfferEscapeOptions: recomputed textSize %d, textLineLength %d.\n',o.textSize,o.textLineLength);
    end
end
assert(isfield(o,'textFont') && ~isempty(o.textFont));
if o.speakEachLetter && o.useSpeech
    Speak('Escape');
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
DrawCounter(o);
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
    nextTrialMsg='Or hit SPACE to resume from where you escaped.';
else
    nextTrialMsg='';
end
string=['You escaped. Any incomplete trial was canceled. ' ...
    'Hit ESCAPE again to quit the whole experiment. '...
    nextBlockMsg nextTrialMsg];
[x,y]=DrawFormattedText(window,string,...
    2*o.textSize,2.5*o.textSize,black,...
    o.textLineLength,[],[],1.3);
% [x,y]=Screen('DrawText',window,...
%     'ZZZPlease slowly type the name of the Experimenter who is sup.ZZZ',...
%     0,y+1.3*o.textSize,black,[],1);
% [x,y]=Screen('DrawText',window,...
%     sprintf('textSize %d, textFont %s, textLineLength %d',...
%     o.textSize,o.textFont,o.textLineLength),...
%     0,y+2.6*o.textSize,black,[],1);
Screen('Flip',window);
answer=GetKeypress(...
    [spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],...
    o.deviceIndex);
quitExperiment=ismember(answer,[escapeChar,graveAccentChar]);
quitBlock=ismember(answer,returnChar)||quitExperiment;
skipTrial=ismember(answer,' ');
if o.useSpeech
    if quitExperiment || quitBlock && o.isLastBlock
        Speak('Done.');
    elseif quitBlock
        Speak('Proceeding to next block.');
    elseif skipTrial
        Speak('Proceeding to next trial.');
    end
end
Screen('FillRect',window);
end