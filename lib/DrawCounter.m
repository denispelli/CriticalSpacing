function bounds=DrawCounter(o)
% bounds=DrawCounter(o);
% Use o.counterPlacement to specify alignment of counter in screenRect.
% Displays "INVALID DATA" when in debugging mode. I.e. whenever
% o.useFractionOfScreenToDebug~=0 or o.skipScreenCalibration=true.
o=o(1); % Allow caller to send o or oo.

global window scratchWindow scratchRect
global blockTrial blockTrials
persistent counterSize counterBounds
% Check arguments and globals.
if isempty(window)
    error('Require open window.');
end
if Screen('WindowKind',window)==0
    error('window is invalid');
end
if Screen('WindowKind',scratchWindow)==0
    error('scratchWindow is invalid');
end
if isempty(scratchWindow)
    [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window);
end
% Compose the message.
message='';
if ~isempty(blockTrial)
    message=sprintf('Trial %d of %d. ',blockTrial,blockTrials);
end
message=sprintf('%sBlock %d of %d.',message,o.block,o.blocksDesired);
if isfield(o,'viewingDistanceCm')
    message=sprintf('%s At %.0f cm.',message,o.viewingDistanceCm);
end
if o.useFractionOfScreenToDebug~=0 || o.skipScreenCalibration
    message=['WARNING: This debugging mode invalidates data. ' message];
end
% Set size and font.
if isfield(o,'textSize')
    counterSize=round(0.6*o.textSize);
else
    counterSize=20;
end
Screen('TextSize',scratchWindow,counterSize);
oldFont=Screen('TextFont',window,'Verdana');
Screen('TextFont',scratchWindow,Screen('TextFont',window));
counterBounds=TextBounds(scratchWindow,message,1);
r=Screen('Rect',window);
% r=o.screenRect;
if isfield(o,'stimulusRect')
    r(3)=o.stimulusRect(3);
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
black=BlackIndex(window);
oldTextSize=Screen('TextSize',window,counterSize);
% Use whatever background is currently in use. Don't insist on white.
Screen('DrawText',window,message,counterBounds(1),counterBounds(2),black,[]);
Screen('TextFont',window,oldFont); % Restore.
Screen('TextSize',window,oldTextSize); % Restore.
bounds=counterBounds;
end