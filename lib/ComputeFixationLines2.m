function fixationLines=ComputeFixationLines2(fix)
%ComputeFixationLines2 returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix".
% fix.x=50;                             % x location of fixation on screen.
% fix.y=screenHeight/2;                 % y location of fixation on screen.
% fix.eccentricityPix=eccentricityPix;  % Positive or negative horizontal
%                                       % offset of target from fixation.
% fix.eccentricityClockwiseAngleDeg=0;  % Orientation of vector from
%                                       % fixation to target.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Full width & height of fixation
%                                       % cross.
% fix.targetCrossPix=1;                 % Draw cross at
%                                       % target location. 0 for none.
% fix.blankingRadiusPix=0.5*eccentricityPix; % 0 for no blanking.
% fixationLines=ComputeFixationLines(fix);
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
% March 14, 2016. Completely rewritten for arbitrary location of fixation
% and target, using my new ClipLineSegment and ErasePartOfLineSegment
% routines.
if ~isfield(fix,'fixationCrossPix')
   fix.targetCross=100; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'targetCrossPix')
   fix.targetCross=0; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'blankingRadiusPix')
   fix.targetCross=fix.eccentricityPix/2; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'fixationCrossBlankedNearTarget')
   fix.fixationCrossBlankedNearTarget=1; % Default is yes.
end
fix.eccentricityXPix=round(fix.eccentricityPix*sind(fix.eccentricityClockwiseAngleDeg));
fix.eccentricityYPix=round(-fix.eccentricityPix*cosd(fix.eccentricityClockwiseAngleDeg));
% We compute a list of four lines to draw crosses at fixation and target
% locations. We clip each line with the clipRect. We then define a blanking rect
% around the target and use it to ErasePartOfLineSegment for every line in
% the list, which may increase or decrease the list length.
x=[fix.x-fix.fixationCrossPix/2 fix.x+fix.fixationCrossPix/2 ...
   fix.x fix.x];
y=[fix.y fix.y ...
   fix.y-fix.fixationCrossPix/2 fix.y+fix.fixationCrossPix/2];
tX=fix.x+fix.eccentricityXPix;
tY=fix.y+fix.eccentricityYPix;
tR=fix.blankingRadiusPix;
assert(isfinite(fix.blankingRadiusPix));
x=[x tX-tR tX+tR tX tX];
y=[y tY tY tY-tR tY+tR];
[x,y]=ClipLineSegment(x,y,fix.clipRect);
if ~isempty(x) && fix.blankingRadiusPix>0
   rect=[-1 -1 1 1]*fix.blankingRadiusPix;
   rect=OffsetRect(rect,tX,tY);
   x
   y
   rect
   [x,y]=ErasePartOfLineSegment(x,y,rect);
end
fixationLines=[x;y];
return
