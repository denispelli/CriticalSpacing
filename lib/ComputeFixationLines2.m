function [fixationLines,isTargetLocationMarked]=ComputeFixationLines2(fix)
% [fixationLines,isTargetLocationMarked]=ComputeFixationLines2(fix);
% ComputeFixationLines2 returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target X as specified by the parameters in
% the struct argument "fix". When the target is at or near fixation, you
% may optionally blank a portion of the markings (i.e. suppress fixation
% marks from a radius centered on the target. This typically leaves several
% line segments that still imply lines intersecting at fixation.
% Furthermore, blanking is restricted to blankingClipRect, which is
% typically use to protect a screen margin from blanking, so some trace of
% each of the X's four branches always remains.
%
% OUTPUT:
% "fixationLines" has two rows, x and y. Each column is a point. Each pair
% of columns specifies a line.
% "isTargetLocationMarked"
%
% INPUT:
% fix.xy==XYPixOfXYDeg(o,[0 0]);        % screen location of fixation
% fix.eccentricityXYPix=eccentricityXYPix;  % xy offset of target from fixation.
% fix.fixationMarkPix=fixationMarkPix;% Diameter of fixation cross.
%                                       % 0 for none.
% fix.isTargetLocationMarked=true;
% fix.targetMarkPix=targetMarkPix;      % Diameter of target mark X
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% unblankableMarginPix=o.fixationUnblankableScreenMarginDeg*pixPerDeg;
% fix.blankingClipRect=InsetRect(screenRect,unblankableMarginPix,unblankableMarginPix);
%
% COMPUTE blankingRadiusPix FROM:
% fix.isFixationBlankedNearTarget=true;
% fix.fixationBlankingRadiusReEccentricity=0.5;
% fix.fixationBlankingRadiusReTargetHeight=1;
% fix.targetHeightPix=o.targetHeightPix;
%
% fixationLines=ComputeFixationLines2(fix);
% Screen('DrawLines',window,fixationLines,fixationThicknessPix,black);
%
% The many calls to round() don't noticeably affect the display. They are
% just to make the values easier to examine while debugging.
%
% HISTORY:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
% March 14, 2016. Completely rewritten for arbitrary location of fixation
% and target, using my new ClipLineSegment and ErasePartOfLineSegment
% routines.
% June 28, 2017. The new code is general, and works correctly for any
% locations of fixation and target. The target mark is now an X, to
% distinguish it from the fixation cross.
% February 18, 2020. Now support the flag
% fix.isFixationBlankedNearTarget.
% June 21, 2020. dgp. ComputeFixationLines2.m now accepts
% fix.blankingClipRect to clip the blanking. This supports a new parameter
% added to CriticalSpacing.m, o.fixationUnblankableScreenMarginDeg
% requesting that fixation lines be protected from blanking in the
% specified screen margin (specified in deg). This guarantees that if
% fixation is onscreen and fix.fixationMarkPix is infinite then there will
% be some visible on-screen residual part of each of the 4 radii of the
% fixation cross. The observer instructions typically ask the observer to
% keep her eyes on the fixation cross, which makes no sense if there isn't
% one. Right now none of my tests mark the target location, and I'm unsure
% whether we should spare blanking of the target mark outside
% blankingClipRect. I coded it to apply the same blankingClipRect to
% both, but perhaps it should apply only to fixation.

if ~isfield(fix,'isFixationBlankedNearTarget')
    fix.isFixationBlankedNearTarget=true;
end
if ~isfield(fix,'fixationMarkPix')
    fix.fixationMarkPix=100;
end
if ~isfield(fix,'isTargetLocationMarked')
    fix.isTargetLocationMarked=false; % Default is no mark indicating target location.
end
if ~isfield(fix,'blankingRadiusPix') || isempty(fix.blankingRadiusPix)
    % We blank (i.e. suppress) any marks near the target to prevent masking
    % and crowding of the target by the marks. The usual blanking radius
    % (centered at target) is the greater of twice the target diameter and
    % half eccentricity.
    eccentricityPix=norm(fix.eccentricityXYPix);
    if ~isfield(fix,'fixationBlankingRadiusReEccentricity')
        o.fixationBlankingRadiusReEccentricity=0.5;
    end
    if ~isfield(fix,'fixationBlankingRadiusReTargetHeight')
        o.fixationBlankingRadiusReTargetHeight=2;
    end
    if ~isfield(fix,'targetHeightPix')
        o.targetHeightPix=0;
    end
    % Default is max of specified blanking re target height and
    % eccentricity.
    eccentricityPix=norm(fix.eccentricityXYPix);
    fix.blankingRadiusPix=fix.fixationBlankingRadiusReEccentricity*eccentricityPix; % 0 for no blanking.
    fix.blankingRadiusPix=max(fix.blankingRadiusPix,fix.fixationBlankingRadiusReTargetHeight*fix.targetHeightPix);
end
if ~fix.isFixationBlankedNearTarget
    fix.fixationBlankingRadiusReTargetHeight=0;
    fix.fixationBlankingRadiusReEccentricity=0;
    fix.blankingRadiusPix=0;
end
if ~isfield(fix,'blankingClipRect') || isempty(fix.blankingClipRect)
    fix.blankingClipRect=fix.clipRect;
end

% Compute a list of four lines to draw a cross at fixation and an X at the
% target location. We clip with clipRect (typically screenRect). We then
% define a blanking rect around the target, which we clip with
% blankingClipRect, and use it to ErasePartOfLineSegment for every line in
% the list. This may increase or decrease the list length.
fix.xy=round(fix.xy); % Printout is more readable for integers.
x0=fix.xy(1); % fixation
y0=fix.xy(2);
% Two lines create a cross at fixation.
x=[x0-fix.fixationMarkPix/2 x0+fix.fixationMarkPix/2 x0 x0];
y=[y0 y0 y0-fix.fixationMarkPix/2 y0+fix.fixationMarkPix/2];
% Target location
tXY=fix.xy+fix.eccentricityXYPix;
tX=tXY(1);
tY=tXY(2);
% Blanking radius at target
assert(isfinite(fix.blankingRadiusPix));
if fix.isTargetLocationMarked
    % Add two lines to mark target location.
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
    %    fix.fixationMarkPix
    %    'Fixation, and marks (at fixation and target), before blanking'
    %    x0,y0
    %    x
    %    y
    %
    % Limit blanking to blankingClipRect.
    blankingRect=ClipRect(blankingRect,fix.blankingClipRect); % dgp June 21, 2020
    [x,y]=ErasePartOfLineSegment(x,y,blankingRect);
    %    'Marks, after blanking'
    %    x
    %    y
    %    blankingRect
end
fixationLines=[x;y];
isTargetLocationMarked=fix.isTargetLocationMarked;
return
