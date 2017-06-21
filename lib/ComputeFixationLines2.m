function fixationLines=ComputeFixationLines2(fix)
% ComputeFixationLines2 returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix".
% fix.xy=[50 screenHeight/2];            %  location of fixation on screen.
% % fix.eccentricityXYPix=eccentricityXYPix;  % xy offset of target from fixation.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Full width & height of fixation
%                                       % cross. 0 for none.
% fix.targetCrossPix=1;                 % Draw cross at
%                                       % target location. 0 for none.
% fix.blankingRadiusPix=0.5*sqrt(sum(eccentricityPix.^2)); % 0 for no blanking.
% fixationLines=ComputeFixationLines2(fix);
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
%
% The many calls to round() don't affect the display. They are just to make
% the values easier to print, while debugging. 
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
% March 14, 2016. Completely rewritten for arbitrary location of fixation
% and target, using my new ClipLineSegment and ErasePartOfLineSegment
% routines.
if ~isfield(fix,'fixationCrossPix')
   fix.fixationCrossPix=100; 
end
if ~isfield(fix,'targetCrossPix')
   fix.targetCross=0; % Default is no mark indicating target location.
end
if ~isfield(fix,'blankingRadiusPix')
   % Default is half the eccentricity.
   eccentricityPix=sqrt(sum(fix.eccentricityXYPix.^2));
   fix.targetCross=eccentricityPix/2;
end
if ~isfield(fix,'fixationCrossBlankedNearTarget')
   fix.fixationCrossBlankedNearTarget=1; % Default is yes.
end
% We compute a list of four lines to draw crosses at fixation and target
% locations. We clip with the (screen) clipRect. We then define a blanking
% rect around the target and use it to ErasePartOfLineSegment for every
% line in the list, which may increase or decrease the list length.
fix.xy=round(fix.xy); % printout is more readable for integers.
x0=fix.xy(1); % fixation
y0=fix.xy(2);
% two lines at fixation
x=[x0-fix.fixationCrossPix/2 x0+fix.fixationCrossPix/2 x0 x0];
y=[y0 y0 y0-fix.fixationCrossPix/2 y0+fix.fixationCrossPix/2];
% target location
tXY=fix.xy+fix.eccentricityXYPix;
tX=tXY(1);
tY=tXY(2);
% blanking radius at target
tR=fix.blankingRadiusPix;
assert(isfinite(fix.blankingRadiusPix));
if fix.targetCrossPix
   % Add two lines at target.
   x=[x tX-tR tX+tR tX tX];
   y=[y tY tY tY-tR tY+tR];
end
%    'Fixation, and marks (at fixation and target), before clipping'
%    x0,y0
%    x
%    y
% Clip to active part of screen.
[x,y]=ClipLineSegment(x,y,fix.clipRect);
x=round(x);
y=round(y);
if ~isempty(x) && fix.blankingRadiusPix>0
   % Blank near target.
   blankingRect=[-1 -1 1 1]*fix.blankingRadiusPix;
   blankingRect=OffsetRect(blankingRect,tX,tY);
   blankingRect=round(blankingRect);
%    'fixation cross pix'
%    fix.fixationCrossPix
%    'Fixation, and marks (at fixation and target), before blanking'
%    x0,y0
%    x
%    y
   [x,y]=ErasePartOfLineSegment(x,y,blankingRect);
%    'Marks, after blanking'
%    x
%    y
%    blankingRect
end
fixationLines=[x;y];
return
