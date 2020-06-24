function bounds=DrawCounter(o)
% bounds=DrawCounter(o);
% Use o.counterPlacement to specify alignment of counter in screenRect.
% Displays "INVALID DATA" when in debugging mode. I.e. whenever
% o.useFractionOfScreenToDebug>0 or o.skipScreenCalibration=true.
% The call to TextBounds2 is very slow (200 ms), so we skip that and use
% the cached counterBounds if the message is unchanged from the
% previousMessage.
global window scratchWindow scratchRect blockTrial blockTrials
persistent counterBounds previousMessage previousWindow

o=o(1); % Allow caller to send o or oo.
%% Check arguments and globals.
if isempty(window)
    error('DrawCounter needs an open window.');
end
if Screen('WindowKind',window)~=1
    error('window is invalid');
end
%% Compose the message.
message='';
if ~isempty(blockTrial)
    message=sprintf('Trial %d of %d. ',blockTrial,blockTrials);
end
if isfield(o,'block') && isfield(o,'blocksDesired')
    message=sprintf('%sBlock %d of %d.',message,o.block,o.blocksDesired);
end
if isfield(o,'viewingDistanceCm')
    message=sprintf('%s At %.0f cm.',message,o.viewingDistanceCm);
end
if (isfield(o,'useFractionOfScreenToDebug') && o.useFractionOfScreenToDebug~=0)...
        || (isfield(o,'skipScreenCalibration') && o.skipScreenCalibration)
    message=['WARNING: This debugging mode invalidates data. ' message];
end
%% Set size and font.
if isfield(o,'textSize')
    counterSize=round(0.6*o.textSize);
else
    counterSize=20;
end
oldTextSize=Screen('TextSize',window,counterSize);
oldFont=Screen('TextFont',window,'Verdana');
%% If necessary, compute and place counterBounds.
if isempty(previousMessage) || ~ismember({message},{previousMessage}) || ~ismember(window,previousWindow)
    if isempty(scratchWindow) || Screen('WindowKind',scratchWindow)~=-1
        [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window);
        if Screen('WindowKind',scratchWindow)~=-1
            error('scratchWindow is invalid');
        end
    end
    Screen('TextSize',scratchWindow,counterSize);
    Screen('TextFont',scratchWindow,Screen('TextFont',window));
    counterBounds=TextBounds2(scratchWindow,message,1);
    if isfield(o,'screenRect')
        r=o.screenRect;
    else
        r=Screen('Rect',window);
    end
    if isfield(o,'stimulusRect') && isfield(o,'alphabetPlacement')
        switch o.alphabetPlacement
            case 'left'
                r(1)=max(r(1),o.stimulusRect(1));
            case 'right'
                r(3)=min(r(3),o.stimulusRect(3));
            case 'top'
                r(2)=max(r(2),o.stimulusRect(2));
            case 'bottom'
                % r(4)=min(r(4),o.stimulusRect(4));
                % We want the counter to always be at the bottom of the screen.
        end
    end
    r=InsetRect(r,counterSize/4,counterSize/8);
    if ~isfield(o,'counterPlacement')
        o.counterPlacement='bottomRight';
    end
    switch o.counterPlacement
        case 'bottomRight'
            counterBounds=AlignRect(counterBounds,r,'right','bottom');
        case 'bottomLeft'
            counterBounds=AlignRect(counterBounds,r,'left','bottom');
        case 'bottomCenter'
            counterBounds=AlignRect(counterBounds,r,'center','bottom');
    end
else
    % Use cached counterBounds.
end
%% Draw counter.
black=BlackIndex(window);
% Use whatever background is currently in use. Don't insist on white.
Screen('DrawText',window,message,counterBounds(1),counterBounds(2),black,[]);
%% Restore settings. Save message.
Screen('TextFont',window,oldFont); % Restore.
Screen('TextSize',window,oldTextSize); % Restore.
bounds=counterBounds;
previousMessage=message;
end