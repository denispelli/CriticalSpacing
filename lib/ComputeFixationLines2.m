function fixationLines=ComputeFixationLines2(fix)
% ComputeFixationLines2 returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix".
% xy=XYPixOfXYDeg(o,[0 0]); % location of fixation
% fix.xy=xy;            %  location of fixation on screen.
% fix.eccentricityXYPix=eccentricityXYPix;  % xy offset of target from fixation.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Width & height of fixation
%                                       % cross. 0 for none.
% fix.markTargetLocation=1;             % 0 or 1.
% fix.targetMarkPix=targetMarkPix;      % 
%
% EITHER SPECIFY blankingRadiusPix:
% fix.blankingRadiusPix=100;              % 0 for no blanking.
% OR LET ME COMPUTE IT FROM:
% fix.blankingRadiusReEccentricity=0.5;
% fix.blankingRadiusReTargetHeight=1;
% fix.targetHeightPix=o.targetHeightPix;
%
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
% June 28, 2017. The new code is general, and works correctly for any
% locations of fixation and target. The target mark is now an X, to
% distinguish it from the fixation cross.
if ~isfield(fix,'fixationCrossPix')
   fix.fixationCrossPix=100; 
end
if ~isfield(fix,'markTargetLocation')
   fix.markTargetLocation=0; % Default is no mark indicating target location.
end
if ~isfield(fix,'blankingRadiusPix')
   if ~isfield(fix,'blankingRadiusReEccentricity');
      o.blankingRadiusReEccentricity=0.5;
   end
   if ~isfield(fix,'blankingRadiusReTargetHeight');
      o.blankingRadiusReTargetHeight=1;
   end
   if ~isfield(fix,'targetHeightPix')
      o.targetHeightPix=0;
   end
   % Default is max of specified blanking re target height and
   % eccentricity.
   eccentricityPix=sqrt(sum(fix.eccentricityXYPix.^2));
   fix.blankingRadiusPix=fix.blankingRadiusReEccentricity*eccentricityPix; % 0 for no blanking.
   fix.blankingRadiusPix=max(fix.blankingRadiusPix,fix.blankingRadiusReTargetHeight*fix.targetHeightPix);
end
% Compute a list of four lines to draw a cross at fixation and an X at the
% target location. We clip with the (screen) clipRect. We then define a
% blanking rect around the target and use it to ErasePartOfLineSegment for
% every line in the list. This may increase or decrease the list length.
fix.xy=round(fix.xy); % printout is more readable for integers.
x0=fix.xy(1); % fixation
y0=fix.xy(2);
% Two lines create a cross at fixation.
x=[x0-fix.fixationCrossPix/2 x0+fix.fixationCrossPix/2 x0 x0];
y=[y0 y0 y0-fix.fixationCrossPix/2 y0+fix.fixationCrossPix/2];
% Target location
tXY=fix.xy+fix.eccentricityXYPix;
tX=tXY(1);
tY=tXY(2);
% Blanking radius at target
assert(isfinite(fix.blankingRadiusPix));
if fix.markTargetLocation
   % Add two lines to mark target location.
%    r=fix.targetMarkPix;
%    x=[x tX-r tX+r tX tX]; % Make a cross.
%    y=[y tY tY tY-r tY+r];
   r=0.5*fix.targetMarkPix/2^0.5;
   r=min(r,1e8); % Need finite value to draw tilted lines.
   x=[x tX-r tX+r tX-r tX+r]; % Make an X.
   y=[y tY-r tY+r tY+r tY-r];
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
