function fixationLines=ComputeFixationLines2(fix)
% ComputeFixationLines2 returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix". When target is at or near fixation, you may
% optionally blank (i.e. suppress fixation marks from a radius centered on
% the target. This typically leaves several line segments that imply lines
% intersecting at fixation.
% xy=XYPixOfXYDeg(o,[0 0]); % screen location of fixation
% fix.xy=xy;                % screen location of fixation.
% fix.eccentricityXYPix=eccentricityXYPix;  % xy offset of target from fixation.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Width & height of fixation
%                                       % cross. 0 for none.
% fix.markTargetLocation=true;          % true or false.
% fix.targetMarkPix=targetMarkPix;      %
% fix.fixationLineMinimumLengthPix=o.fixationLineMinimumLengthDeg*o.pixPerDeg;
% fix.targetHeightPix=o.targetHeightPix;
%
% fix.blankingRadiusPix=0;              % 0 for no blanking.
% fix.blankingRadiusPix=100;            % >0 for user-specified blanking.
% fix.blankingRadiusPix=[];             % [] for automatic blanking.
% fix.blankingRadiusReEccentricity=0.5; % default
% fix.blankingRadiusReTargetHeight=2;   % default
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
% distinguish it from the fixation cross +.
if ~isfield(fix,'fixationCrossPix')
    fix.fixationCrossPix=100;
end
if ~isfield(fix,'markTargetLocation')
    fix.markTargetLocation=0; % Default is no mark indicating target location.
end
if ~isfield(fix,'blankingRadiusReEccentricity')
    fix.blankingRadiusReEccentricity=0.5;
end
if ~isfield(fix,'blankingRadiusReTargetHeight')
    fix.blankingRadiusReTargetHeight=2;
end
if ~isfield(fix,'targetHeightPix')
    fix.targetHeightPix=0;
end
if ~isfield(fix,'blankingRadiusPix') || isempty(fix.blankingRadiusPix)
    % We blank (i.e. suppress) any marks near the target to prevent masking
    % and crowding of the target by the marks. The usual blanking radius
    % (centered at target) is the greater of twice the target diameter and
    % half eccentricity.
    eccentricityPix=norm(fix.eccentricityXYPix);
    fix.blankingRadiusPix=max(...
        fix.blankingRadiusReEccentricity*eccentricityPix,...
        fix.blankingRadiusReTargetHeight*fix.targetHeightPix);
end
if ~isfield(fix,'fixationLineMinimumLengthPix')
    fix.fixationLineMinimumLengthDeg=100;
end
if isempty(fix.blankingRadiusPix) || fix.blankingRadiusPix>0
    % Added March, 2019, by denis.pelli@nyu.edu.
    % Here we apply a ceiling on the blanking radius so that fixation
    % marking is not entirely blanked, and still indicates to the observer
    % where to fixate. First we restrict the blanking radius to be less
    % than the screen size, then we increase the fixation mark radius to
    % exceed the blanking, so that we show at least two marks with length
    % at least fix.fixationCrossPix. Typically the display is symmetric so
    % we get all four marks.
    diameter=fix.targetHeightPix;
    %     if oo(oi).targetSizeIsHeight
    %         diameter=diameter*max(1,1/oo(oi).targetHeightOverWidth);
    %     else
    %         diameter=diameter*max(1,oo(oi).targetHeightOverWidth);
    %     end
    eccentricityPix=norm(fix.eccentricityXYPix);
    % Here we retrict the blanking radius so that the remaining fixation
    % marks still indicate where the observer should fixate. There
    % are four points where an infinite on-screen fixation cross
    % crosses an edge of the screen. For the crossings to indicate
    % fixation location, we need to retain at least one on a
    % vertical edge and one on a horizontal edge. So we compute the
    % largest blanking radius that would spare at least both a
    % vertical and a horizontal crossing. That would be a radius
    % equal to the minimum of two distances, each of which is
    % the maximum of the distance from fixation of the two points
    % with the same edge orientation. We reduce the blanking radius
    % below that value by a user-specified minimum edge marker
    % length in deg. Thus we guarantee that the observer will be
    % shown at least two fixation marks, horizontal and vertical,
    % possibly far from fixation, with length at least
    % fixationLineMinimumLengthDeg.
    fXY=fix.xy; % fixation
    tXY=fix.eccentricityXYPix+fXY; % target
    crossingXY{1}=[fXY(1) fix.clipRect(2)];
    crossingXY{2}=[fXY(1) fix.clipRect(4)];
    crossingXY{3}=[fix.clipRect(1) fXY(2)];
    crossingXY{4}=[fix.clipRect(3) fXY(2)];
    d=[];
    for i=1:4
        d(i)=norm(crossingXY{i}-tXY);
    end
    r=min(max([d(1:2)' d(3:4)'])); % Spare at least one horiz. and one vert. crossing.
    minPix=fix.fixationLineMinimumLengthPix;
    r=r-minPix; % spare at least this (e.g. 0.5 deg).
    if ~isfinite(fix.blankingRadiusPix)
        % If we have a definite blanking radius, then use it. If not,
        % then use this rule of thumb to limit it.
        fix.blankingRadiusPix=round(min([fix.blankingRadiusPix r]));
    end
    % We make sure that we display least a minimal amount
    % fix.fixationLineMinimumLengthDeg of each fixation mark, by making
    % sure that the requested fixation mark extends beyond blanking by that
    % amount, on both sides.
    fix.fixationCrossPix=max(fix.fixationCrossPix,...
        2*(fix.blankingRadiusPix+minPix));
end

% Compute a list of four lines to draw a cross at fixation and an X at the
% target location. We clip with clipRect (typically screenRect). We then
% define a blanking rect around the target and use it to
% ErasePartOfLineSegment for every line in the list. This may increase or
% decrease the list length.
fix.xy=round(fix.xy); % Printout is more readable for integers.
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
    r=0.5*fix.targetMarkPix/2^0.5;
    r=min(r,1e8); % Need finite value to draw tilted lines.
    x=[x tX-r tX+r tX-r tX+r]; % Make an X.
    y=[y tY-r tY+r tY+r tY-r];
end
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
